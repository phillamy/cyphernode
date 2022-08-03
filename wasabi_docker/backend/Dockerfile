FROM mcr.microsoft.com/dotnet/sdk:6.0-bullseye-slim AS build
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1

RUN git clone -b v2.0.1.3 --depth 1 https://github.com/zkSNACKs/WalletWasabi.git /src

WORKDIR /src

RUN dotnet restore "WalletWasabi.Backend/WalletWasabi.Backend.csproj"

WORKDIR "/src/WalletWasabi.Backend"
RUN dotnet build "WalletWasabi.Backend.csproj" -c Release -o /app/build

RUN dotnet publish "WalletWasabi.Backend.csproj" -c Release -o /app/publish


FROM mcr.microsoft.com/dotnet/aspnet:6.0-bullseye-slim

ENV DOTNET_CLI_TELEMETRY_OPTOUT=1

WORKDIR /app
COPY --from=build /app/publish .
COPY docker-entrypoint.sh docker-entrypoint.sh

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["/app/docker-entrypoint.sh"]