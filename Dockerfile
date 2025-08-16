FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

COPY ./src/HelloWorld/*.csproj ./src/HelloWorld/
RUN dotnet restore ./src/HelloWorld/HelloWorld.csproj

COPY ./src/HelloWorld/ ./src/HelloWorld/
RUN dotnet publish ./src/HelloWorld/HelloWorld.csproj -c Release -o /out \
    -p:PublishReadyToRun=true \
    -p:PublishSingleFile=true \
    -p:InvariantGlobalization=true \
    -p:TieredPGO=true \
    --self-contained=false

FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
ENV ASPNETCORE_URLS=http://0.0.0.0:8080 \
    ASPNETCORE_ENVIRONMENT=Production \
    DOTNET_EnableDiagnostics=0

WORKDIR /app

RUN useradd -r -u 10001 appuser

COPY --from=build /out/ /app/
EXPOSE 8080
USER 10001
ENTRYPOINT ["./HelloWorld"]
