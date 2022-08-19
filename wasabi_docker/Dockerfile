FROM mcr.microsoft.com/dotnet/sdk:6.0-bullseye-slim AS build
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1

RUN git clone -b master --depth 1 https://github.com/zkSNACKs/WalletWasabi.git /wasabi
WORKDIR /wasabi

#RUN git fetch origin pull/8962/head:MASTER
#RUN git checkout MASTER

WORKDIR /wasabi/WalletWasabi.Fluent.Desktop
#RUN dotnet restore "WalletWasabi.Fluent.Desktop.csproj"
#RUN dotnet build "WalletWasabi.Fluent.Desktop.csproj" -c Release -o /app/build

#RUN dotnet publish "WalletWasabi.Fluent.Desktop.csproj" -c Release -o /app/publish

RUN dotnet build -c Release -o /app/ -r linux-x64
RUN dotnet publish --output /app/ -c Release --disable-parallel --no-cache /p:DebugType=none /p:DebugSymbols=false /p:ErrorReport=none

FROM mcr.microsoft.com/dotnet/aspnet:6.0-bullseye-slim

RUN apt-get update && apt-get install -y xvfb jq curl libfontconfig1 wget gpg procps vim && apt-get clean

ENV DOTNET_CLI_TELEMETRY_OPTOUT=1

WORKDIR /app
COPY --from=build /app/ .
COPY docker-entrypoint.sh docker-entrypoint.sh

#EXPOSE 80
#EXPOSE 443

#ENTRYPOINT ["/app/docker-entrypoint.sh"]