# QT

# 基础使用

## 在Clion中使用

1. 新建项目
  
   一般选择c++ 14，qt5

2. 更新cmakelist
  
   ```
   // 在原有基础上更新
   set(REQUIRED_LIBS Core Widgets )
   set(REQUIRED_LIBS_QUALIFIED Qt5::Core Qt5::Widgets )
   ```

3. **新建qt ui类**
  
   创建mainwindow类，此时会有三个文件
   
   ![](src/2023-02-23-22-50-47-image.png)

> 可以用qt designer编辑ui文件，在terminal中，输入`designer`，然后打开文件
> 
> 因为该项目是打开了qt的`auto generate`的，所以在构建项目的时候，会重新读入`mainwindow.ui`文件，然后在`/cmake-build-debug/qt_autogen/include/ui_mainwindow.h`中生成响应的头文件

4. 运行
  
   此时的`main.cpp`应为：
   
   ```cpp
   #include <QCoreApplication>
   #include <QDebug>
   #include <QApplication>
   #include "mainwindow.h"
   int main(int argc, char *argv[]) {
       QApplication a (argc, argv);
       mainwindow w;
       w.show ();
       return QApplication::exec ();
   }
   ```

## 显示点云项目

1. 更新`cmakelists`，需要用到`vtk pcl opencv`等库

```
cmake_minimum_required(VERSION 3.10)
project(qt)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

set(QT_VERSION 5)
set(REQUIRED_LIBS Core Widgets )
set(REQUIRED_LIBS_QUALIFIED Qt5::Core Qt5::Widgets )

add_executable(${PROJECT_NAME} main.cpp mainwindow.cpp mainwindow.h mainwindow.ui pcdProcess.cpp pcdProcess.h)

#if (NOT CMAKE_PREFIX_PATH)
#    message(WARNING "CMAKE_PREFIX_PATH is not defined, you may need to set it "
#            "(-DCMAKE_PREFIX_PATH=\"path/to/Qt/lib/cmake\" or -DCMAKE_PREFIX_PATH=/usr/include/{host}/qt{version}/ on Ubuntu)")
#endif ()
find_package(VTK REQUIRED)
find_package(Qt${QT_VERSION} COMPONENTS ${REQUIRED_LIBS} REQUIRED)
find_package(PCL REQUIRED)
find_package(OpenCV REQUIRED)
message(${PCL_LIBRARIES})

include(${VTK_USE_FILE})

#修改
#target_link_libraries(${PROJECT_NAME} Qt5::Widgets ${VTK_LIBRARIES})

target_link_libraries(${PROJECT_NAME} ${REQUIRED_LIBS_QUALIFIED} ${VTK_LIBRARIES} ${PCL_LIBRARIES} ${OpenCV_LIBS})
```

2. 新建一个qt ui类，命名为`mainwindow`，此时会生成三个文件。

3. 修改`mainwindow.h`,一般做类函数、类变量的声明

```cpp
//
// Created by sophda on 2/23/23.
//

#ifndef QT_MAINWINDOW_H
#define QT_MAINWINDOW_H

#include <QWidget>
#include <pcl/visualization/cloud_viewer.h>

#include <vtkRenderWindow.h>


QT_BEGIN_NAMESPACE
namespace Ui { class mainwindow; }
QT_END_NAMESPACE

class mainwindow : public QWidget {
Q_OBJECT

public:
    explicit mainwindow(QWidget *parent = nullptr);
    void btn_openpcd();
    ~mainwindow() override;

private:
    Ui::mainwindow *ui;

    pcl::visualization::PCLVisualizer::Ptr viewer;
};

#endif //QT_MAINWINDOW_H
```

4. 修改`mainwindow.cpp`,一般做类函数定义

> 1.信号与槽的连接：connect; `connect(ui->pushButton, &QPushButton::clicked,this, &mainwindow::btn_openpcd);`
> 
> `ui->pushButton`指：ui文件中的pushbutton控件，发出信号
> 
> `btn_openpcd`指：作为槽函数，响应信号。用connect连接起来

```cpp
//
// Created by sophda on 2/23/23.
//

// You may need to build the project (run Qt uic code generator) to get "ui_mainwindow.h" resolved

#include <pcl/io/pcd_io.h>
#include "mainwindow.h"
#include "ui_mainwindow.h"

mainwindow::mainwindow(QWidget *parent) :
        QWidget(parent), ui(new Ui::mainwindow) {
    ui->setupUi(this);
    // init signal and slot
    connect(ui->pushButton, &QPushButton::clicked, this, &mainwindow::btn_openpcd);


    // pcl function

    viewer.reset(new pcl::visualization::PCLVisualizer("viewer", false));
    ui->widget->SetRenderWindow(viewer->getRenderWindow());
    viewer->setupInteractor(ui->widget->GetInteractor(), ui->widget->GetRenderWindow());
    ui->widget->update();



}

mainwindow::~mainwindow() {
    delete ui;
}

void mainwindow::btn_openpcd() {

    pcl::PointCloud<pcl::PointXYZ>::Ptr cloud(new pcl::PointCloud<pcl::PointXYZ>);
    char strfilepath[256] = "../src/leaf.pcd";
    if (-1 == pcl::io::loadPCDFile(strfilepath, *cloud))
    {
        cout << "error input!" << endl;
        return;
    }

    std::cout << "read completed" << std::endl;
    cout << cloud->points.size() << endl;
    viewer->addPointCloud(cloud);


}
```

5. 在`qt designer`中修改控件

新建一个`widget`；然后右键**提升控件**，提升为：（注意头文件要大写）

> 在vtk控件中嵌套一个pcl中的viewer，然后就可以显示点云了

![](src/2023-02-23-23-12-11-image.png)

6. 然后就可以运行了哦~

![](src/2023-02-23-23-17-58-image.png)

## 显示图片

> 使用ui中的label显示图片

在对应的槽函数中填写

```cpp
   ui->textEdit->setText("hello world!");
   Mat img = imread("/home/icecreamshao/108.bmp");

   Mat temp;
   cvtColor(img, temp, CV_BGR2RGB);
   QImage Qtemp = QImage((const unsigned char*)(temp.data), temp.cols, temp.rows, temp.step, QImage::Format_RGB888);
   ui->label->setPixmap(QPixmap::fromImage(Qtemp));
   ui->label->resize(Qtemp.size());
   ui->label->show();
```







# FFmpeg

## api

**1.初始化与注册：**

- av_register_all()

  **作用**: 这是旧版 FFmpeg API 的一个初始化函数。它的作用是注册所有可用的文件格式（muxers/demuxers）和编解码器（codecs）。在程序开始使用 FFmpeg 功能之前，必须先调用这个函数，否则 `avformat_open_input`、`avcodec_find_decoder` 等函数将无法找到对应的组件。

  **注意**: 这个函数在 FFmpeg 4.0 版本之后被标记为**废弃 (deprecated)**。在新版中，组件是自动注册的，你不再需要手动调用此函数。如果需要网络功能，可以调用 `avformat_network_init()`。



**2.打开媒体文件与获取信息**

- `avformat_alloc_context()`

  **作用**: 分配一个 `AVFormatContext` 结构体的内存。`AVFormatContext` 是一个核心结构体，它包含了媒体文件的所有格式信息，如封装格式、时长、码率、包含的流等。

  **返回值**: 成功时返回一个指向分配的 `AVFormatContext` 的指针，失败时返回 `NULL`。

- `avformat_open_input(AVFormatContext **ps, const char *url, AVInputFormat *fmt, AVDictionary **options)`

  **作用**：打开一个媒体文件或流，并读取文件头信息，填充`AVFormatContext` 结构。它会自动探测文件的封装格式。

  - `&pFormatCtx`: 指向 `AVFormatContext` 指针的指针。函数会在这里填充分配好的结构体。

  - `filepath`: 要打开的文件的路径或 URL。

  - `NULL`: 指定输入格式。传入 `NULL` 表示让 FFmpeg 自动检测。

  - `NULL`: 附加选项，用于配置 demuxer。传入 `NULL` 表示使用默认选项。

- `avformat_find_stream_info(AVFormatContext *ic, AVDictionary **options)`

  **作用**: 读取媒体文件的数据包来获取流信息。`avformat_open_input` 只读取了文件头，可能信息不全。此函数会进一步解析数据，填充 `pFormatCtx->streams` 数组中每个流的详细信息，例如视频的宽高、帧率、编码格式等。

  **参数详解**:

  - `pFormatCtx`: 已经通过 `avformat_open_input` 打开的 `AVFormatContext`。
  - `NULL`: 附加选项。

  **返回值**: 成功返回 `>= 0`，失败返回一个负值的错误码。



**3.查找解码器并打开**

- `avcodec_find_decoder(enum AVCodecID id)`

  **作用**: 根据指定的编码器 ID，在 FFmpeg 已注册的解码器列表中查找对应的解码器。

  **参数详解**:

  - `pCodecCtx->codec_id`: 这是一个 `AVCodecID` 枚举值，表示视频流的编码格式（如 `AV_CODEC_ID_H264`, `AV_CODEC_ID_MPEG4` 等）。这个 ID 是在调用 `avformat_find_stream_info` 后从 `pFormatCtx->streams[videoindex]->codec->codec_id` 中获取的。

  **返回值**: 成功时返回指向 `AVCodec` 结构体的指针，找不到则返回 `NULL`。`AVCodec` 代表了解码器本身，包含了它的功能和实现。



- `avcodec_open2(AVCodecContext *avctx, const AVCodec *codec, AVDictionary **options)`

  **作用**: 使用指定的 `AVCodec` 来初始化 `AVCodecContext`。这一步是真正打开解码器的操作，之后解码器上下文才能用于解码。

  **参数详解**:

  - `pCodecCtx`: 需要被初始化的解码器上下文。这个上下文是从 `pFormatCtx->streams[videoindex]->codec` 中获取的，包含了流的参数。
  - `pCodec`: 上一步通过 `avcodec_find_decoder` 找到的解码器。
  - `NULL`: 附加的解码器配置选项。

  **返回值**: 成功返回 `0`，失败返回一个负值的错误码。



**4.内存分配与数据准备**

- `av_frame_alloc()`

  **作用**: 分配一个 `AVFrame` 结构体的内存。`AVFrame` 用于存放解码后的原始音视频数据（对于视频，就是一帧图像）。这个函数仅仅分配了 `AVFrame` 结构本身的内存，并不包含图像数据的缓冲区。

  **返回值**: 成功时返回指向 `AVFrame` 的指针，失败时返回 `NULL`。

- `av_malloc(size_t size)`

  **作用**: FFmpeg 内部的内存分配函数，功能类似于标准库的 `malloc`。推荐使用它来分配需要被 FFmpeg 其他函数使用的内存，因为它可以保证内存对齐，对多媒体处理有性能优势。

- `av_image_get_buffer_size(enum AVPixelFormat pix_fmt, int width, int height, int align)`

  **作用**: 根据指定的像素格式、图像宽度、高度和对齐方式，计算存储一帧图像所需的内存大小（字节数）。

  **参数详解**:

  - `AV_PIX_FMT_RGB32`: 目标像素格式，这里是带 Alpha 通道的 32 位 RGB。
  - `pCodecCtx->width`: 视频宽度。
  - `pCodecCtx->height`: 视频高度。
  - `1`: 对齐方式。`1` 表示不需要特殊的对齐。



- `av_image_fill_arrays(uint8_t *dst_data[4], int dst_linesize[4], const uint8_t *src, enum AVPixelFormat pix_fmt, int width, int height, int align)`

  **作用**: 将一块已分配的内存（`out_buffer`）与 `AVFrame` 的 `data` 和 `linesize` 字段关联起来。它会根据图像参数，正确地设置 `pFrameRGB->data` 指针数组和 `pFrameRGB->linesize` 数组。

  **参数详解**:

  - `pFrameRGB->data`: `AVFrame` 的数据指针数组，函数会填充这个数组。例如 `data[0]` 会指向图像数据的起始地址。
  - `pFrameRGB->linesize`: `AVFrame` 的行大小数组，函数会填充这个数组。`linesize[0]` 表示图像第一平面中每一行所占的字节数。
  - `out_buffer`: 指向之前用 `av_malloc` 分配的内存块的指针。
  - `AV_PIX_FMT_RGB32`, `pCodecCtx->width`, `pCodecCtx->height`, `1`: 图像的格式和尺寸信息。



- `av_image_fill_arrays(uint8_t *dst_data[4], int dst_linesize[4], const uint8_t *src, enum AVPixelFormat pix_fmt, int width, int height, int align)`

  **作用**: 将一块已分配的内存（`out_buffer`）与 `AVFrame` 的 `data` 和 `linesize` 字段关联起来。它会根据图像参数，正确地设置 `pFrameRGB->data` 指针数组和 `pFrameRGB->linesize` 数组。

  **参数详解**:

  - `pFrameRGB->data`: `AVFrame` 的数据指针数组，函数会填充这个数组。例如 `data[0]` 会指向图像数据的起始地址。
  - `pFrameRGB->linesize`: `AVFrame` 的行大小数组，函数会填充这个数组。`linesize[0]` 表示图像第一平面中每一行所占的字节数。
  - `out_buffer`: 指向之前用 `av_malloc` 分配的内存块的指针。
  - `AV_PIX_FMT_RGB32`, `pCodecCtx->width`, `pCodecCtx->height`, `1`: 图像的格式和尺寸信息。



**5.格式信息打印**

- `av_dump_format(AVFormatContext *ic, int index, const char *url, int is_output)`

  **作用**: 一个非常方便的调试函数，它会将 `AVFormatContext` 中包含的关于媒体文件的详细信息（如格式、时长、码率、各个流的详细参数等）打印到标准错误输出（`stderr`）。

  **参数详解**:

  - `pFormatCtx`: 要打印信息的 `AVFormatContext`。
  - `0`: 流的索引，这里是 `0` 表示打印所有流的信息。
  - `filepath`: 关联的文件名，会显示在打印信息中。
  - `0`: 标志位，`0` 表示这是输入流，`1` 表示是输出流。



**6.图像格式转换**

- `sws_getContext(int srcW, int srcH, enum AVPixelFormat srcFormat, int dstW, int dstH, enum AVPixelFormat dstFormat, int flags, SwsFilter *srcFilter, SwsFilter *dstFilter, const double *param)`

  **作用**: 分配并初始化一个 `SwsContext` 结构体。这个上下文用于后续的图像缩放和像素格式转换操作。

  **参数详解**:

  - `pCodecCtx->width`, `pCodecCtx->height`, `pCodecCtx->pix_fmt`: 源图像的宽、高和像素格式（通常是某种 YUV 格式）。
  - `pCodecCtx->width`, `pCodecCtx->height`, `AV_PIX_FMT_RGB32`: 目标图像的宽、高和像素格式。这里宽高不变，只是转换格式。
  - `SWS_BICUBIC`: 指定缩放算法，`SWS_BICUBIC` 是一种质量较好的算法。
  - `NULL`, `NULL`, `NULL`: 其他高级滤波选项，这里不使用。

  **返回值**: 成功时返回一个指向 `SwsContext` 的指针，失败时返回 `NULL`。



**7.核心循环：读取、解码与转换**

- `av_read_frame(AVFormatContext *s, AVPacket *pkt)`
  - **作用**: 从媒体文件中读取一个数据包（`AVPacket`）。这个包里包含的是一帧压缩后的视频数据或音频数据。函数会自动处理文件内部的交错存储等问题。
  - **参数详解**:
    - `pFormatCtx`: 格式上下文。
    - `packet`: 一个指向 `AVPacket` 的指针，函数会把读取到的数据填充到这个结构体中。
  - **返回值**: 成功返回 `0`；如果读取到文件末尾，会返回 `AVERROR_EOF` 或其他负的错误码。

- `avcodec_decode_video2(AVCodecContext *avctx, AVFrame *picture, int *got_picture_ptr, const AVPacket *avpkt)`

  **作用**: 解码一帧视频数据。它接收一个包含压缩数据的 `AVPacket`，解码后将原始图像数据填充到 `AVFrame` 中。

  **参数详解**:

  - `pCodecCtx`: 解码器上下文。
  - `pFrame`: 用于接收解码后图像数据的 `AVFrame`。
  - `&got_picture`: 一个整型指针，函数会通过它返回是否成功解码出一帧完整的图像。如果成功，`got_picture` 的值会被设为非零。
  - `packet`: 包含待解码数据的 `AVPacket`。

  **返回值**: 成功时返回消耗的字节数，失败时返回一个负的错误码。

  **注意**: 这个函数也已被**废弃**。新的 API 使用 `avcodec_send_packet()` 和 `avcodec_receive_frame()` 的组合来代替，新 API 能更好地处理 B 帧等复杂情况。



- `sws_scale(struct SwsContext *c, const uint8_t *const srcSlice[], const int srcStride[], int srcSliceY, int srcSliceH, uint8_t *const dst[], const int dstStride[])`

  **作用**: 执行核心的图像转换操作。根据 `sws_getContext` 中设置的参数，将源图像（`pFrame`，YUV 格式）进行缩放和像素格式转换，并将结果输出到目标图像（`pFrameRGB`，RGB32 格式）。

  **参数详解**:

  - `img_convert_ctx`: 之前创建的 `SwsContext`。
  - `(const unsigned char* const*)pFrame->data`, `pFrame->linesize`: 源图像的数据和行大小数组。
  - `0`, `pCodecCtx->height`: 源图像处理的起始行和总行数。
  - `pFrameRGB->data`, `pFrameRGB->linesize`: 目标图像的数据和行大小数组。

  **返回值**: 输出图像的高度。



- `av_free_packet(AVPacket *pkt)`

  **作用**: 释放由 `av_read_frame` 分配的 `AVPacket` 内部的数据缓冲区。每次循环处理完一个 packet 后都应该调用它，以防内存泄漏。

  **注意**: 这个函数也已被**废弃**。新版 API 使用 `av_packet_unref()` 来代替，它会减少 packet 的引用计数，当计数为零时释放其数据。



**8.资源释放与清理**

- `sws_freeContext(struct SwsContext *swsContext)`

  **作用**: 释放由 `sws_getContext` 分配的 `SwsContext` 结构体。

- `av_frame_free(AVFrame frame)`

  作用**: 释放 `AVFrame` 及其相关的数据缓冲区。它会先调用 `av_frame_unref`，如果引用计数为零，则释放 `AVFrame` 结构本身。

- `avcodec_close(AVCodecContext *avctx)`

  **作用**: 关闭解码器并释放相关的 `AVCodecContext` 资源。

- `avformat_close_input(AVFormatContext s)`

  **作用**: 关闭输入的媒体文件，并释放 `AVFormatContext` 及其所有相关的内部资源。



## 在qt界面中进行渲染

```
void mainwindow::on_play_clicked() {
    AVFormatContext    *pFormatCtx;
    int                i, videoindex;
    AVCodecContext    *pCodecCtx;
    AVCodec            *pCodec;
    AVFrame    *pFrame, *pFrameRGB;
    unsigned char *out_buffer;
    AVPacket *packet;
    int ret, got_picture;
    struct SwsContext *img_convert_ctx;

    char filepath[] = "/home/sophda/videoProject/VideoPlayer/1.mp4";
    //初始化编解码库
    // av_register_all();//创建AVFormatContext对象，与码流相关的结构。
    pFormatCtx = avformat_alloc_context();
    //初始化pFormatCtx结构
    if (avformat_open_input(&pFormatCtx, filepath, NULL, NULL) != 0){
        printf("Couldn't open input stream.\n");
        return ;
    }
    //获取音视频流数据信息
    if (avformat_find_stream_info(pFormatCtx, NULL) < 0){
        printf("Couldn't find stream information.\n");
        return ;
    }
    videoindex = -1;
    //nb_streams视音频流的个数，这里当查找到视频流时就中断了。
    for (i = 0; i < pFormatCtx->nb_streams; i++)
        if (pFormatCtx->streams[i]->codec->codec_type == AVMEDIA_TYPE_VIDEO){
            videoindex = i;
            break;
    }
    if (videoindex == -1){
        printf("Didn't find a video stream.\n");
        return ;
    }
    //获取视频流编码结构
    pCodecCtx = pFormatCtx->streams[videoindex]->codec;
    //查找解码器
    pCodec = avcodec_find_decoder(pCodecCtx->codec_id);
    if (pCodec == NULL){
        printf("Codec not found.\n");
        return ;
    }
    //用于初始化pCodecCtx结构
    if (avcodec_open2(pCodecCtx, pCodec, NULL) < 0){
        printf("Could not open codec.\n");
        return ;
    }
    //创建帧结构，此函数仅分配基本结构空间，图像数据空间需通过av_malloc分配
    pFrame = av_frame_alloc();
    pFrameRGB = av_frame_alloc();
    //创建动态内存,创建存储图像数据的空间
    //av_image_get_buffer_size获取一帧图像需要的大小
    out_buffer = (unsigned char *)av_malloc(av_image_get_buffer_size(AV_PIX_FMT_RGB32, pCodecCtx->width, pCodecCtx->height, 1));
    av_image_fill_arrays(pFrameRGB->data, pFrameRGB->linesize, out_buffer,
        AV_PIX_FMT_RGB32, pCodecCtx->width, pCodecCtx->height, 1);

    packet = (AVPacket *)av_malloc(sizeof(AVPacket));
    //Output Info-----------------------------
    printf("--------------- File Information ----------------\n");
    //此函数打印输入或输出的详细信息
    av_dump_format(pFormatCtx, 0, filepath, 0);
    printf("-------------------------------------------------\n");
    //初始化img_convert_ctx结构
    img_convert_ctx = sws_getContext(pCodecCtx->width, pCodecCtx->height, pCodecCtx->pix_fmt,
        pCodecCtx->width, pCodecCtx->height, AV_PIX_FMT_RGB32, SWS_BICUBIC, NULL, NULL, NULL);
    //av_read_frame读取一帧未解码的数据
    while (av_read_frame(pFormatCtx, packet) >= 0){
        //如果是视频数据
        if (packet->stream_index == videoindex){
            //解码一帧视频数据
            ret = avcodec_decode_video2(pCodecCtx, pFrame, &got_picture, packet);
            if (ret < 0){
                printf("Decode Error.\n");
                return ;
            }
            if (got_picture){
                sws_scale(img_convert_ctx, (const unsigned char* const*)pFrame->data, pFrame->linesize, 0, pCodecCtx->height,
                    pFrameRGB->data, pFrameRGB->linesize);
                QImage img((uchar*)pFrameRGB->data[0],pCodecCtx->width,pCodecCtx->height,QImage::Format_RGB32);
                ui->label->setPixmap(QPixmap::fromImage(img));
                Delay(10);
            }
        }
        // av_free_packet(packet);
    }
    sws_freeContext(img_convert_ctx);
    av_frame_free(&pFrameRGB);
    av_frame_free(&pFrame);
    avcodec_close(pCodecCtx);
    avformat_close_input(&pFormatCtx);
}
```





