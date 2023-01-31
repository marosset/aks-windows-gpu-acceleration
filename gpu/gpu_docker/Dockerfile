FROM mcr.microsoft.com/windows:10.0.17763.3887

WORKDIR C:/App

COPY ["tinyyolov2-7.tar.gz", "c:/App/"]

# Download and extract the ONNX model to be used for evaluation.
RUN tar.exe -xf tinyyolov2-7.tar.gz && \
    del tinyyolov2-7.tar.gz

# Download and extract cli tool for evaluation .onnx model with WinML.
RUN curl.exe -L -o WinMLRunner_x64_Release.zip https://github.com/microsoft/Windows-Machine-Learning/releases/download/1.2.1.1/WinMLRunner.v1.2.1.1.zip && \
    tar.exe -xf C:/App/WinMLRunner_x64_Release.zip && \
    del WinMLRunner_x64_Release.zip

# Run the model evaluation when container starts.
ENTRYPOINT ["C:/App/WinMLRunner v1.2.1.1/x64/WinMLRunner.exe", "-model", "C:/App/model/model.onnx", "-terse", "-iterations", "100", "-perf"]
