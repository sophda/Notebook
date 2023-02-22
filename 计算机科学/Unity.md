# Unity

*COPYRIGHT @ SOPHDA *

# Unity基础操作

使用unity个人版，教程链接：[2.3 Unity窗口布局_哔哩哔哩_bilibili](https://www.bilibili.com/video/BV1TZ4y1o76s?p=6&vd_source=bd4e6ed09b1d6487743fbfd26167e229)

## 窗口布局

![](src/2023-02-07-05-33-05-image.png)

- Hierarchy 层级，双击层级里的对象可以放到视野中心
  
  ![](src/2023-02-07-05-42-17-image.png)

- 场景 可以理解为一个关卡
  
  ![](src/2023-02-07-05-42-40-image.png)

## 3D视图操作

- 导航器 gizmo 表示世界坐标的方向
  
  懒子（z）穿着红裤衩（x）
  
  >  1.点shift+小方块：重置，是y轴朝上
  > 
  > 2.点击x、y、z以不同视角来看
  
  ![](src/2023-02-07-05-45-02-image.png)

- 栅格 grid 表示xz坐标平面![](src/2023-02-07-05-47-03-image.png)

- 天空盒 skybox
  
  ![](src/2023-02-07-05-48-49-image.png)

## 坐标系

左手坐标系，伸出你的左手

<img src="src/2023-02-07-05-55-51-image.png" title="" alt="" data-align="center">

## 摄像机

调整摄像机到当前视角：align with view

![](src/2023-02-07-06-49-36-image.png)

## 播放模式

点击play按钮后，会进入播放模式，值得注意的是：<u>在播放模式下做的任何修改都不会生效哦~</u>

# C#脚本

## 编写与挂载

> 设置脚本编辑器:
> 
> Unity：Edit->Preferences->ExternalTools->External Script Editor选择Visual Studio Code

1.在assets里面新建c#脚本

2.选择要挂载的对象，比如tube，然后将脚本拖到审查器（inspector）里，即可完成挂载

## 类操作

每一个函数都是一个类，类名与文件名必须一致

```csharp
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Basic_logic : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        Debug.Log("**hello");
        GameObject obj = this.gameObject;
// this表示本脚本，this.gameObject表示
// 本脚本挂载的对象
        string name = obj.name;
        Debug.Log(name);

        Transform trans = this.gameObject.transform;
// 读取transform值
        Vector3 pos = this.gameObject.transform.position;
        Debug.Log(pos);
    }

    // Update is called once per frame
    void Update()
    {

    }
}
```

## 物体坐标

> 父子关系：将一个对象移到另一个对象下面，构成父子关系。可以在移动父对象时，子对象也跟着动弹。
> 
> 如下图，cube和plane就构成了父子关系：
> 
> <img title="" src="src/2023-02-07-11-03-24-image.png" alt="" data-align="center">

**1.作为子对象的cube就有两种坐标：**

- 全局坐标 transform.position

- 局部坐标 transform.localPosition

*只有transform对象才有这种属性*

```csharp
Transform trans = this.gameObject.transform;
Debug.Log("localpos: "+trans.localPosition+" position: "+trans.position);
```

![](src/2023-02-07-11-10-42-image.png)

**2.物体坐标设置**

```csharp
this.transform.localPosition = new Vector3(0, 10, 0);
// transform很常用,所以这句话就是指向了this.gameObject.transform
```

<img src="src/2023-02-07-11-26-35-image.png" title="" alt="" data-align="center">

## 帧更新

update方法，在每一帧更新的时候都会调用这个方法。

**观察帧率：**

- Time.time 游戏当前帧的时间

- Time.deltatime 游戏距离上帧的时间

**设定期望帧率：**

```csharp
void Start()
{
Application.targetFrameRate = 60;
        // 期望的帧率
}
```

## 陀螺仪

> 使用的unity engine给的api，参考链接：[Unity的陀螺仪实现_J L-X的博客-CSDN博客_unity 陀螺仪](https://blog.csdn.net/weixin_43665612/article/details/115330643)(这里的蓝色栏表示的是补充说明哦~）

code:直接挂载到maincamera上就行

```csharp
// A code block
using UnityEngine;
using System.Collections;

public class camera : MonoBehaviour
{
    private const float lowPassFilterFactor = 0.8f;

    private Quaternion startQuaternion;

    private Quaternion originalQuaternion;

    private int frameCnt = 0;

    void Start()
    {
        //设置设备陀螺仪的开启/关闭状态，使用陀螺仪功能必须设置为 true  
        Input.gyro.enabled = true;
        //获取设备重力加速度向量  
        Vector3 deviceGravity = Input.gyro.gravity;
        //设备的旋转速度，返回结果为x，y，z轴的旋转速度，单位为（弧度/秒）  
        Vector3 rotationVelocity = Input.gyro.rotationRate;
        //获取更加精确的旋转  
        Vector3 rotationVelocity2 = Input.gyro.rotationRateUnbiased;
        //设置陀螺仪的更新检索时间，即隔 0.1秒更新一次  
        Input.gyro.updateInterval = 0.1f;
        //获取移除重力加速度后设备的加速度  
        Vector3 acceleration = Input.gyro.userAcceleration;
    }

    void Update()
    {
        frameCnt++;

        if (frameCnt > 5 && frameCnt <= 30)
        {
            originalQuaternion = transform.rotation;

            startQuaternion = new Quaternion(-1 * Input.gyro.attitude.x,
            -1 * Input.gyro.attitude.y,
            Input.gyro.attitude.z,
            Input.gyro.attitude.w);
            return;
        }

        Quaternion currentQuaternion = new Quaternion(-1 * Input.gyro.attitude.x, -1 * Input.gyro.attitude.y,
            Input.gyro.attitude.z, Input.gyro.attitude.w);

        //Quaternion deltaQuaternion = Quaternion.RotateTowards(startQuaternion, currentQuaternion, 180);

        //Input.gyro.attitude 返回值为 Quaternion类型，即设备旋转欧拉角  
        //transform.rotation = Quaternion.Slerp(transform.rotation, new Quaternion(-1*Input.gyro.attitude.x, -1*Input.gyro.attitude.y, Input.gyro.attitude.z, Input.gyro.attitude.w), lowPassFilterFactor);
        transform.rotation = Quaternion.Slerp(transform.rotation, originalQuaternion * Quaternion.Inverse(startQuaternion) * currentQuaternion, lowPassFilterFactor);
    }
}
```

## 镜头自由移动

```csharp
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class movecam : MonoBehaviour
{
    private float speed = 4f;

    private Transform tr;

    private Vector3 mpStart;
    private Vector3 originalRotation;

    private float t = 0f;

    // 
    void Awake()
    {
        tr = GetComponent<Transform>();
        t = Time.realtimeSinceStartup;
    }

    // 
    void Update()
    {
        // Movement
        float forward = 0f;
        if (Input.GetKey(KeyCode.W) || Input.GetKey(KeyCode.UpArrow)) { forward += 1f; }
        if (Input.GetKey(KeyCode.S) || Input.GetKey(KeyCode.DownArrow)) { forward -= 1f; }

        float right = 0f;
        if (Input.GetKey(KeyCode.D) || Input.GetKey(KeyCode.RightArrow)) { right += 1f; }
        if (Input.GetKey(KeyCode.A) || Input.GetKey(KeyCode.LeftArrow)) { right -= 1f; }

        float up = 0f;
        if (Input.GetKey(KeyCode.E) || Input.GetKey(KeyCode.Space)) { up += 1f; }
        if (Input.GetKey(KeyCode.Q) || Input.GetKey(KeyCode.C)) { up -= 1f; }

        float dT = Time.realtimeSinceStartup - t;
        t = Time.realtimeSinceStartup;

        tr.position += tr.TransformDirection(new Vector3(right, up, forward) * speed * (Input.GetKey(KeyCode.LeftShift) ? 2f : 1f) * dT);

        // Rotation
        Vector3 mpEnd = Input.mousePosition;

        // Right Mouse Button Down
        if (Input.GetMouseButtonDown(1))
        {
            originalRotation = tr.localEulerAngles;
            mpStart = mpEnd;
        }

        // Right Mouse Button Hold
        if (Input.GetMouseButton(1))
        {
            Vector2 offs = new Vector2((mpEnd.x - mpStart.x) / Screen.width, (mpStart.y - mpEnd.y) / Screen.height);
            tr.localEulerAngles = originalRotation + new Vector3(offs.y * 360f, offs.x * 360f, 0f);
        }
    }
}
```

# CardBoard

您可以使用 Cardboard SDK 将智能手机转变成 VR 平台。智能手机可以呈现立体呈现的 3D 场景、跟踪头部移动并做出反应，还能通过检测用户何时按观看者按钮来与应用互动。

## 设置开发环境

- unity 2020.3.36f1,提供Android支持

- 安装git

## 导入SDK

1. 打开 Unity 并创建新的 **3D** 项目。

2. 在 Unity 中，依次转到 **Window** > **Package Manager**。

3. 点击 **+**，然后选择 **Add package from git 网址**。

4. 将 `https://github.com/googlevr/cardboard-xr-plugin.git` 粘贴到文本输入字段中。  
   应将软件包添加到已安装的软件包。![](src/2023-02-10-20-55-34-image.png)

5. 转到**适用于 Unity 的 Google Cardboard XR 插件**软件包。在**示例**部分中，选择**导入到项目中**。  
   示例资源应加载到 `Assets/Samples/Google Cardboard/<version>/Hello Cardboard`。
   
   > 这一步直接在project里面选择

6. 转到 `Assets/Samples/Google Cardboard/<version>/Hello Cardboard/Scenes`，选择 **Add Open Scenes**，然后选择 **HelloCardboard** 以打开示例场景。

## 配置 Android 项目设置

依次转到 **File** &gt **Build Settings**。

1. 选择 **Android**，然后选择**切换平台**。
2. 选择 **Add Open Scenes**，然后选择 **HelloCardboard**。

依次转到 **Project Settings** > **Player** > **Resolution and Presentation**。

1. 将**默认方向**设为**横向**或**横向**。
2. 停用**经过优化的帧同步**。

**other settings**

> 这一步非常关键，正确配置sdk版本和架构

依次转到 **Project Settings** > **Player** > **Other Settings**。

1. 在 **Graphics API** 中选择 `OpenGLES2`、`OpenGLES3` 或 `Vulkan` 或它们的任意组合。
2. 在**最低 API 级别**中选择 `Android 7.0 'Nougat' (API level 24)` 或更高版本。
3. 在**目标 API 级别**中选择 `API level 31` 或更高版本。
4. 在 **Scripting Backend** 中选择 `IL2CPP`。
5. 在**目标架构**中选择 `ARMv7` 和/或 `ARM64`，以选择所需的架构。
6. 在**互联网访问**中选择 `Require`。
7. 在**软件包名称**下指定您的公司域名。
8. 如果选择 `Vulkan` 作为 **Graphics API**：
   - 取消选中 **Vulkan 设置**中的**在渲染过程中应用显示屏旋转**复选框。
   - 如果 Unity 版本为 2021.2 或更高版本，请选择**纹理压缩格式**中的 `ETC2`。

**发布设置**

依次转到 **Project Settings** &gt **Player** &**Publishing Settings**

1. 在 **Build** 部分中，选择 `Custom Main Gradle Template` 和 `Custom Gradle Properties Template`。

2. 将以下代码行添加到 `Assets/Plugins/Android/mainTemplate.gradle` 的依赖项部分：
   
   ```
   implementation 'androidx.appcompat:appcompat:1.4.2'  implementation 'com.google.android.gms:play-services-vision:20.1.3'  implementation 'com.google.android.material:material:1.6.1'implementation 'com.google.protobuf:protobuf-javalite:3.19.4'
   ```

3. 将以下几行代码添加到 `Assets/Plugins/Android/gradleTemplate.properties`：
   
   ```
   android.enableJetifier=true  
   android.useAndroidX=true
   ```

**XR插件管理**

依次转到 **Project Settings**（项目设置）和 **XR Plug-in Management**（XR 插件管理）。

1. 在**插件提供程序**下选择 `Cardboard XR Plugin`。

**构建您的项目**

依次转到 **File** &gt **Build Settings**。

1. 选择 **Build**，或选择设备并选择 **Build and Run**。

**其他**

依次转到 **Project Settings** > **Player** > **Other Settings**。

1. 在**相机使用说明**中，输入 `Cardboard SDK requires camera permission to read the QR code (required to get the encoded device parameters).`。
2. 在**目标 iOS 最低版本**中，输入 `12.0`。
3. 在**软件包名称**下指定您的公司域名。

**XR 插件管理设置**

依次转到 **Project Settings**（项目设置）和 **XR Plug-in Management**（XR 插件管理）。

1. 在**插件提供程序**下选择 `Cardboard XR Plugin`。

## 镜头移动--camera为root

> cardboard提供的是rotation和position的跟踪（加载默认的hello cardboard场景的情况下），我们要**使用手机跟踪rotation，用键盘的wasd来控制移动**

1. 将player中的camera移出来，然后删除player，然后将`camera->tracked pos driver->tracking type`中改为`rotation only`即可

![](src/2023-02-21-02-45-10-image.png)

2. 然后要监听键盘wasd，只需要在camera脚本上添加监听即可。完整cs：

```csharp
//-----------------------------------------------------------------------
// <copyright file="CameraPointer.cs" company="Google LLC">
// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// </copyright>
//-----------------------------------------------------------------------

using System.Collections.Generic;
using System.Collections;
using UnityEngine;

/// <summary>
/// Sends messages to gazed GameObject.
/// </summary>
public class CameraPointer : MonoBehaviour
{
    private const float _maxDistance = 10;
    private GameObject _gazedAtObject = null;

    /// <summary>
    /// Update is called once per frame.
    /// </summary>
    /// 

    private float speed = 4f;

    private Transform tr;

    private Vector3 mpStart;
    private Vector3 originalRotation;
    private Vector3 rot;
    private Vector3 zero = new Vector3(0,0,0);

    private float t = 0f;

    // 
    void Awake()
    {
        tr = GetComponent<Transform>();
        t = Time.realtimeSinceStartup;


    }
    public void Start()
    {
       // tr.localEulerAngles = zero;
    }


    public void Update()
    {

        // Movement
        float forward = 0f;
        if (Input.GetKey(KeyCode.W) || Input.GetKey(KeyCode.UpArrow)) { forward += 1f; }
        if (Input.GetKey(KeyCode.S) || Input.GetKey(KeyCode.DownArrow)) { forward -= 1f; }

        float right = 0f;
        if (Input.GetKey(KeyCode.D) || Input.GetKey(KeyCode.RightArrow)) { right += 1f; }
        if (Input.GetKey(KeyCode.A) || Input.GetKey(KeyCode.LeftArrow)) { right -= 1f; }

        float up = 0f;
        if (Input.GetKey(KeyCode.E) || Input.GetKey(KeyCode.Space)) { up += 1f; }
        if (Input.GetKey(KeyCode.Q) || Input.GetKey(KeyCode.C)) { up -= 1f; }

        float dT = Time.realtimeSinceStartup - t;
        //float dT = Time.deltaTime;
        t = Time.realtimeSinceStartup;

        tr.position += tr.TransformDirection(new Vector3(right, up, forward) * speed * (Input.GetKey(KeyCode.LeftShift) ? 2f : 1f) * dT);

        Debug.Log(tr.position);

        // Casts ray towards camera's forward direction, to detect if a GameObject is being gazed
        // at.
        RaycastHit hit;
        if (Physics.Raycast(transform.position, transform.forward, out hit, _maxDistance))
        {
            // GameObject detected in front of the camera.
            if (_gazedAtObject != hit.transform.gameObject)
            {
                // New GameObject.
                _gazedAtObject?.SendMessage("OnPointerExit");
                _gazedAtObject = hit.transform.gameObject;
                _gazedAtObject.SendMessage("OnPointerEnter");
            }
        }
        else
        {
            // No GameObject detected in front of the camera.
            _gazedAtObject?.SendMessage("OnPointerExit");
            _gazedAtObject = null;
        }

        // Checks for screen touches.
        if (Google.XR.Cardboard.Api.IsTriggerPressed)
        {
            _gazedAtObject?.SendMessage("OnPointerClick");
        }


    }

}
```

## 镜头移动--player为root

> 在不断地debug过程中，发现cardboard改变的是localeula角度，所以给camera一个父级player，控制player和camera是不可取的。因为localeular是改变的。

所以，为了加入碰撞检测，需要给camera增加父对象player，但是不用添加任何控制脚本，只需要添加`Rigridbody`和`capsule collider`即可，前者刚体增加重力效果，后者增加碰撞检测效果。

然后将camera控制脚本放到player下面即可。相当于player只是起到了碰撞检测+重力的效果。

![](src/2023-02-22-03-43-47-image.png)

## 一些坑

1.项目导出的时候会报错（build and run时），一般改下路径即可

2.直接在官方默认的hellocardboard里面开始折腾就可以了哦~

3.官方的light要调节一下，否则看不清地形的材质
