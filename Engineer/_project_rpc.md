# MyRPC



# 1 server端

## server服务器

```c++
#include <asio/asio.hpp>
#include <iostream>
#include <memory>
#include <unordered_map>
#include <functional>
#include "rpc_protocol.hpp"
#include "rpc_packer.hpp"

using asio::ip::tcp;

class rpc_server : public std::enable_shared_from_this<rpc_server> {
public:
    rpc_server(asio::io_context& io_context, short port)
        : acceptor_(io_context, tcp::endpoint(tcp::v4(), port)),
          socket_(io_context) {
        do_accept();
    }

    // 注册一个 RPC 函数
    template <typename F>
    void register_handler(const std::string& name, F func) {
        handlers_[name] = [func](msgpack::object_handle oh) -> msgpack::sbuffer {
            // 这是类型擦除和动态调用的核心
            // 我们需要从 msgpack object 中解包出函数参数
            // 并调用函数，然后打包返回值
            // 为了简化，我们假设函数签名为 R(Args...)
            using function_type = decltype(func);
            // C++17 的 if constexpr 能极大地简化这里的 SFINAE 或模板特化
            if constexpr (std::is_invocable_v<function_type>) { // 无参数函数
                 if constexpr (std::is_void_v<std::invoke_result_t<function_type>>) {
                    func();
                    return rpc_packer::pack_args(); // 返回一个空的包
                 } else {
                    auto result = func();
                    return rpc_packer::pack_args(result);
                 }
            } else {
                // 有参数的函数... 这里需要更复杂的解包逻辑
                // 下面的代码展示了一个简化的例子，假设我们知道参数类型
                // 一个真正的框架需要更通用的解包机制
                // 这里我们仅为示例展示一个 int(int, int) 的情况
                try {
                    auto args_tuple = oh.get().as<std::tuple<std::string, int, int>>();
                    auto result = std::apply(
                        [&](const std::string&, int a, int b) { return func(a, b); }, 
                        args_tuple
                    );
                    return rpc_packer::pack_args(result);
                } catch (const std::exception& e) {
                    std::cerr << "Dispatch error: " << e.what() << std::endl;
                    // 返回错误信息
                    return rpc_packer::pack_args("error", std::string(e.what()));
                }
            }
        };
    }
    
    // 简化版的注册，仅用于演示
    template<typename R, typename... Args>
    void bind(const std::string& name, std::function<R(Args...)> func) {
        handlers_[name] = [func](msgpack::object_handle oh) -> msgpack::sbuffer {
            try {
                // 从 msgpack object 中剥离函数名，获取参数 tuple
                auto tuple_with_name = oh.get().as<std::tuple<std::string, Args...>>();
                auto args_tuple = tuple_pop_front(tuple_with_name);

                // 调用函数
                if constexpr (std::is_void_v<R>) {
                    std::apply(func, args_tuple);
                    return rpc_packer::pack_args(); // 返回空
                } else {
                    R result = std::apply(func, args_tuple);
                    return rpc_packer::pack_args(result);
                }
            } catch (const std::exception& e) {
                std::cerr << "Dispatch error: " << e.what() << std::endl;
                return rpc_packer::pack_args("error", std::string(e.what()));
            }
        };
    }


private:
    // Helper to remove the first element (function name) from the tuple
    template<typename T, typename... Ts>
    static std::tuple<Ts...> tuple_pop_front(const std::tuple<T, Ts...>& t) {
        return std::apply([](auto&&, auto&&... args){ return std::make_tuple(args...); }, t);
    }
    
    void do_accept() {
        acceptor_.async_accept(socket_, [this](asio::error_code ec) {
            if (!ec) {
                std::make_shared<session>(std::move(socket_), handlers_)->start();
            }
            do_accept();
        });
    }

    // Session class to handle a single client connection
    class session : public std::enable_shared_from_this<session> {
    public:
        session(tcp::socket socket, std::unordered_map<std::string, std::function<msgpack::sbuffer(msgpack::object_handle)>>& handlers)
            : socket_(std::move(socket)), handlers_(handlers) {}

        void start() {
            do_read_header();
        }

    private:
        void do_read_header() {
            auto self = shared_from_this();
            asio::async_read(socket_, asio::buffer(&header_, sizeof(header_)),
                [this, self](asio::error_code ec, std::size_t /*length*/) {
                    if (!ec) {
                        do_read_body();
                    }
                });
        }

void do_read_body() {
            auto self = shared_from_this();
            body_buffer_.resize(header_.body_size);
            asio::async_read(socket_, asio::buffer(body_buffer_.data(), header_.body_size),
                [this, self](asio::error_code ec, std::size_t length) {
                    if (!ec) {
                        // 反序列化
                        msgpack::object_handle oh = msgpack::unpack(body_buffer_.data(), length);
                        msgpack::object obj = oh.get();

                        // 校验数据包格式并提取函数名
                        if (obj.type != msgpack::type::ARRAY || obj.via.array.size == 0) {
                            // 无效的请求格式
                            msgpack::sbuffer error_buffer = rpc_packer::pack_args("error", "Invalid request format");
                            do_write(error_buffer);
                            return;
                        }

                        // 【修改点】直接从 msgpack object 中提取函数名
                        std::string func_name = obj.via.array.ptr[0].as<std::string>();
                        
                        auto it = handlers_.find(func_name);
                        if (it != handlers_.end()) {
                            // 找到函数，执行并获取结果
                            // 将整个 object_handle 传递给处理函数
                            msgpack::sbuffer result_buffer = it->second(std::move(oh));
                            do_write(result_buffer);
                        } else {
                            // 函数未找到
                             msgpack::sbuffer error_buffer = rpc_packer::pack_args("error", "Function not found: " + func_name);
                             do_write(error_buffer);
                        }
                    }
                });
        }
        
        void do_write(const msgpack::sbuffer& buffer) {
            auto self = shared_from_this();
            rpc_header header{static_cast<uint32_t>(buffer.size())};
            std::vector<asio::const_buffer> buffers;
            buffers.push_back(asio::buffer(&header, sizeof(header)));
            buffers.push_back(asio::buffer(buffer.data(), buffer.size()));
            
            asio::async_write(socket_, buffers,
                [this, self](asio::error_code ec, std::size_t /*length*/) {
                    if (!ec) {
                        // 等待下一个请求
                        do_read_header();
                    }
                });
        }

        tcp::socket socket_;
        std::unordered_map<std::string, std::function<msgpack::sbuffer(msgpack::object_handle)>>& handlers_;
        rpc_header header_;
        std::vector<char> body_buffer_;
    };

    tcp::acceptor acceptor_;
    tcp::socket socket_;
    std::unordered_map<std::string, std::function<msgpack::sbuffer(msgpack::object_handle)>> handlers_;
};
```

### 类成员变量

```
tcp::acceptor acceptor_;
tcp::socket socket_;
std::unordered_map<std::string, std::function<msgpack::sbuffer(msgpack::object_handle)>> handlers_;
```

- `tcp::acceptor acceptor_;`

- `tcp::socket socket_;`
- `std::unordered_map<std::string, std::function<msgpack::sbuffer(msgpack::object_handle)>> handlers_;`句柄，注册的函数存放在这个哈希表中。
  - 其中键为函数名
  - 值为函数function对象。这个对象表示输入值是`msgpack::object_handle`，输出值是`msgpack::sbuffer`
  - `msgpack::sbuffer`表示一个序列化缓冲区或者输出缓冲区
  - `msgpack::object_handle`表示反序列化后的MessagePack数据对象。

### 注册函数 bind

```c++
// 简化版的注册，仅用于演示
template<typename R, typename... Args>
void bind(const std::string& name, std::function<R(Args...)> func) {
    handlers_[name] = [func](msgpack::object_handle oh) -> msgpack::sbuffer {
        try {
            // 从 msgpack object 中剥离函数名，获取参数 tuple
            auto tuple_with_name = oh.get().as<std::tuple<std::string, Args...>>();
            auto args_tuple = tuple_pop_front(tuple_with_name);

            // 调用函数
            if constexpr (std::is_void_v<R>) {
                std::apply(func, args_tuple);
                return rpc_packer::pack_args(); // 返回空
            } else {
                R result = std::apply(func, args_tuple);
                return rpc_packer::pack_args(result);
            }
        } catch (const std::exception& e) {
            std::cerr << "Dispatch error: " << e.what() << std::endl;
            return rpc_packer::pack_args("error", std::string(e.what()));
        }
    };
}
```

调用：

```
server.bind("add", std::function<int(int, int)>(add));
```

---

根据调用去推导bind的形参以及模板参数：

- 实参中的`std::function<int(int, int)>(add)`去对应形参中的`std::function<R(Args...)> func`参数，则Args...是个参数包，对应int，int。R对应返回类型，即int。那么模板可以推导为：`template<int, int, int>`
- 往哈希表中放的主要是一个lambda表达式



### 接受数据并处理 do_read_body

```c++
void do_read_body() {
            auto self = shared_from_this();
            body_buffer_.resize(header_.body_size);
            asio::async_read(socket_, asio::buffer(body_buffer_.data(), header_.body_size),
                [this, self](asio::error_code ec, std::size_t length) {
                    if (!ec) {
                        // 反序列化
                        msgpack::object_handle oh = msgpack::unpack(body_buffer_.data(), length);
                        msgpack::object obj = oh.get();

                        // 校验数据包格式并提取函数名
                        if (obj.type != msgpack::type::ARRAY || obj.via.array.size == 0) {
                            // 无效的请求格式
                            msgpack::sbuffer error_buffer = rpc_packer::pack_args("error", "Invalid request format");
                            do_write(error_buffer);
                            return;
                        }

                        // 【修改点】直接从 msgpack object 中提取函数名
                        std::string func_name = obj.via.array.ptr[0].as<std::string>();
                        
                        auto it = handlers_.find(func_name);
                        if (it != handlers_.end()) {
                            // 找到函数，执行并获取结果
                            // 将整个 object_handle 传递给处理函数
                            msgpack::sbuffer result_buffer = it->second(std::move(oh));
                            do_write(result_buffer);
                        } else {
                            // 函数未找到
                             msgpack::sbuffer error_buffer = rpc_packer::pack_args("error", "Function not found: " + func_name);
                             do_write(error_buffer);
                        }
                    }
                });
        }
```

















## 序列化

```
#include <msgpack.hpp>
#include <string>
#include <tuple>

// 序列化器
class rpc_packer {
public:
    // 序列化任意数量和类型的参数
    template <typename... Args>
    static msgpack::sbuffer pack_args(const Args&... args) {
        msgpack::sbuffer buffer;
        // 使用 tuple 将所有参数打包成一个 msgpack array
        msgpack::pack(buffer, std::make_tuple(args...));
        return buffer;
    }

    // 特化一个用于打包 RPC 调用的函数
    template <typename... Args>
    static msgpack::sbuffer pack_call(const std::string& func_name, const Args&... args) {
        msgpack::sbuffer buffer;
        msgpack::pack(buffer, std::make_tuple(func_name, args...));
        return buffer;
    }

    // 解包到指定的 tuple 类型
    template <typename... Args>
    static std::tuple<Args...> unpack(const char* data, size_t length) {
        msgpack::object_handle oh = msgpack::unpack(data, length);
        msgpack::object obj = oh.get();
        return obj.as<std::tuple<Args...>>();
    }
};
```





























