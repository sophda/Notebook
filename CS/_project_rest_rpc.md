# rest rpc



好的，我们来详细梳理一下 `rest_rpc` 中一次完整的RPC调用（以客户端发起同步调用为例）所涉及到的核心函数调用流程，以及它们分别在哪个类中起作用。

这个过程就像一次精心编排的接力赛，数据在客户端和服务器之间传递，每个类和函数都扮演着不可或缺的角色。



### 调用流程图 (简化版)

```
sequenceDiagram
    participant C as 用户代码 (Client)
    participant RC as rpc_client
    participant Codec as msgpack_codec
    participant Net as 网络传输
    participant RS as rpc_server
    participant Conn as connection
    participant Router as router
    participant S as 用户代码 (Server)

    C->>RC: call<T>("add", 1, 2)
    RC->>Codec: pack_args(1, 2)
    Codec-->>RC: 返回打包好的二进制数据
    RC->>Net: write(请求头 + 二进制数据)
    Net->>RS: 接收到新连接
    RS->>Conn: 创建 connection 对象并启动
    Conn->>Net: read_head()
    Net-->>Conn: 返回请求头
    Conn->>Net: read_body()
    Net-->>Conn: 返回二进制数据
    Conn->>Router: route(函数ID, 二进制数据)
    Router->>Codec: unpack<tuple>(二进制数据)
    Codec-->>Router: 返回参数元组 (1, 2)
    Router->>S: 调用已注册的 add(1, 2) 函数
    S-->>Router: 返回结果 (3)
    Router->>Codec: pack_args_str(OK, 3)
    Codec-->>Router: 返回打包好的响应数据
    Router-->>Conn: 返回响应数据
    Conn->>Net: response(响应数据)
    Net-->>RC: 接收到响应数据
    RC->>Codec: unpack<T>(响应数据)
    Codec-->>RC: 返回结果 (3)
    RC-->>C: 返回最终结果 T(3)
```

------



### **详细步骤分解**





#### **第一阶段：客户端发起请求**



1. **用户发起调用**
   - **函数**: `rpc_client::call<T>(rpc_name, args...)`
   - **作用**: 这是用户能直接接触到的调用入口。用户提供函数名和参数。它内部会调用 `async_call` 并同步等待结果。
   - **所在类**: `rpc_client`
2. **打包参数**
   - **函数**: `rpc_client::async_call()` -> `msgpack_codec::pack_args(args...)`
   - **作用**: `async_call` 函数首先会调用 `msgpack_codec` 的 `pack_args` 方法。这个方法负责将用户传入的所有参数（如 `1`, `2`）序列化成 MessagePack 格式的二进制数据。
   - **所在类**: `rpc_client` 调用 `msgpack_codec`。
3. **准备并发送数据**
   - **函数**: `rpc_client::write(req_id, type, message, func_id)`
   - **作用**: `async_call` 准备好所有信息（请求ID、请求类型、函数名哈希、打包好的参数）后，调用 `write` 方法。`write` 方法会：
     1. 创建一个包含魔数、长度、请求ID等信息的**请求头** (`rpc_header`)。
     2. 将请求头和打包好的参数二进制数据放入发送队列 `outbox_`。
     3. 通过 `asio::async_write` 将请求头和数据体一并异步发送到网络socket。
   - **所在类**: `rpc_client`



#### **第二阶段：服务器处理请求**



1. **接受连接**
   - **函数**: `rpc_server::do_accept()`
   - **作用**: 服务器的 `acceptor_` 监听到新的连接请求，`do_accept` 被触发。它会创建一个新的 `connection` 对象来专门处理这个客户端的所有后续通信。
   - **所在类**: `rpc_server`
2. **启动连接并读取数据**
   - **函数**: `connection::start()` -> `connection::read_head()` -> `connection::read_body()`
   - **作用**:
     1. `start()` 是新连接的入口，它立即调用 `read_head()`。
     2. `read_head()` 通过 `asio::async_read` 从socket中读取固定长度的请求头。
     3. 解析出请求头中的消息体长度后，调用 `read_body()` 来读取相应长度的二进制数据（即客户端打包的参数）。
   - **所在类**: `connection`
3. **路由和分发**
   - **函数**: `connection::read_body()` -> `router::route(func_id, data, ...)`
   - **作用**: `read_body` 在成功读取消息体后，将从请求头中得到的函数哈希ID（`func_id`）和消息体数据（`data`）交给 `router` 的 `route` 方法进行处理。
   - **所在类**: `connection` 调用 `router`。
4. **解包参数并执行函数**
   - **函数**: `router::route()` -> `invoker_lambda` -> `msgpack_codec::unpack<T>()` -> **用户注册的函数**
   - **作用**:
     1. `route` 方法在内部的 `map_invokers_` 哈希表中根据 `func_id` 查找到一个预先注册好的lambda函数（调用器）。
     2. 执行这个lambda。lambda内部首先调用 `msgpack_codec::unpack()` 将二进制数据反序列化成一个参数元组（`std::tuple`）。
     3. 然后，通过模板元编程技巧，将元组中的参数解开，并用这些参数**最终调用用户在服务器启动时注册的原始RPC函数**（例如 `dummy::add`）。
   - **所在类**: `router` 调用 `msgpack_codec` 和用户代码。



#### **第三阶段：服务器返回响应**



1. **打包并发送响应**
   - **函数**: `router::route()` -> `connection::response(req_id, result_data)` -> `connection::write()`
   - **作用**:
     1. 用户函数执行完毕后，`router` 将返回值（如果有）和成功状态码通过 `msgpack_codec::pack_args_str` 打包成新的二进制数据。
     2. 这个打包好的响应数据被传给 `connection::response` 方法。
     3. `response` 方法将响应数据放入该连接的写队列 `write_queue_`，并调用 `connection::write()`。
     4. `write()` 同样会创建一个响应头，并通过 `asio::async_write` 将响应头和响应数据发送回客户端。
   - **所在类**: `router` 调用 `connection`。



#### **第四阶段：客户端接收并处理响应**



1. **接收并解析响应**
   - **函数**: `rpc_client::do_read()` -> `rpc_client::read_body()`
   - **作用**: 客户端的 `do_read` 循环一直在等待网络数据。当服务器的响应到达时，它同样会先读取响应头，再读取响应体。
   - **所在类**: `rpc_client`
2. **匹配请求并设置结果**
   - **函数**: `rpc_client::read_body()` -> `rpc_client::call_back(req_id, data)`
   - **作用**: `read_body` 在收到完整的响应数据后，调用 `call_back` 函数。`call_back` 函数会根据响应头中的 `req_id` 在 `future_map_` 中找到之前保存的 `std::promise` 对象。
   - **所在类**: `rpc_client`
3. **解包并返回最终结果**
   - **函数**: `rpc_client::call_back()` -> `promise->set_value(req_result)` -> `rpc_client::call()` -> `req_result::as<T>()`
   - **作用**:
     1. `call_back` 将收到的二进制数据封装成一个 `req_result` 对象，并通过 `promise->set_value()` 将其设置到 `future` 中。
     2. 此时，在第一步中阻塞等待的 `rpc_client::call()` 函数会立即从 `future.get()` 获得这个 `req_result` 对象。
     3. 最后，`call()` 函数调用 `req_result::as<T>()`，它内部再次使用 `msgpack_codec::unpack()` 将二进制数据解包成用户期望的最终类型 `T`，并返回给用户。
   - **所在类**: `rpc_client` 调用 `req_result`，`req_result` 内部调用 `msgpack_codec`。

至此，一次完整的RPC调用流程结束。



# 文件构成

## 调用顺序

1.函数句柄 rpc_server.h

```
  template <bool is_pub = false, typename Function, typename Self>
  void register_handler(std::string const &name, const Function &f,
                        Self *self) {
    router_.register_handler<is_pub>(name, f, self);
  }
```

2.到router中

```
  template <bool is_pub = false, typename Function>
  void register_handler(std::string const &name, Function f, bool pub = false) {
    uint32_t key = MD5::MD5Hash32(name.data()); // 使用MD5将函数名转换为32位整数键
    if (key2func_name_.find(key) != key2func_name_.end()) {
      throw std::invalid_argument("duplicate registration key !");
    } else {
      key2func_name_.emplace(key, name);
      return register_nonmember_func<is_pub>(key, std::move(f));
    }
  }
```

---



```
  /// @brief 生成并注册一个用于调用非成员函数的lambda（调用器）
  template <bool is_pub, typename Function>
  void register_nonmember_func(uint32_t key, Function f) {
    this->map_invokers_[key] = [f](std::weak_ptr<connection> conn,
                                   nonstd::string_view str,
                                   std::string &result) {
      // 使用function_traits获取函数的参数类型，并放入一个元组
      using args_tuple = typename function_traits<Function>::bare_tuple_type;
      msgpack_codec codec;
      try {
        // 1. 从二进制数据中解包出参数元组
        auto tp = codec.unpack<args_tuple>(str.data(), str.size());
        // 2. 对参数进行预处理（主要用于订阅模式）
        helper_t<args_tuple, is_pub>{tp}();
        // 3. 调用实际的RPC函数
        call(f, conn, result, std::move(tp));
      } catch (const std::exception &e) {
        // 异常处理
        result = codec.pack_args_str(result_code::FAIL, e.what());
      }
    };
  }
```

```
  // 存储从函数哈希键到具体调用器的映射。
  // 调用器是一个lambda，它封装了反序列化、函数调用和序列化返回值的整个过程。
  std::unordered_map<uint32_t,
                     std::function<void(std::weak_ptr<connection>,
                                        nonstd::string_view, std::string &)>>
      map_invokers_;
```

```
  /// @brief (非成员函数) 调用封装，处理非void返回值
  /// SFINAE: 仅当函数F返回非void时，此模板才有效
  template <typename F, typename... Args>
  static typename std::enable_if<!std::is_void<typename std::result_of<
      F(std::weak_ptr<connection>, Args...)>::type>::value>::type
  call(const F &f, std::weak_ptr<connection> ptr, std::string &result,
       std::tuple<Args...> tp) {
    auto r = call_helper(f, nonstd::make_index_sequence<sizeof...(Args)>{},
                         std::move(tp), ptr);
    // 将返回值和OK状态码一起打包
    result = msgpack_codec::pack_args_str(result_code::OK, r);
  }
```

---



```
  /// @brief (非成员函数) 调用辅助函数
  /// 使用索引序列和std::tuple来展开参数并调用目标函数
  template <typename F, size_t... I, typename... Args>
  static typename std::result_of<F(std::weak_ptr<connection>, Args...)>::type
  call_helper(const F &f, const nonstd::index_sequence<I...> &,
              std::tuple<Args...> tup, std::weak_ptr<connection> ptr) {
    return f(ptr, std::move(std::get<I>(tup))...);
  }
```

---

```
d
```

























