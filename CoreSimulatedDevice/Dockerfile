FROM mcr.microsoft.com/dotnet/core/runtime:3.0-buster-slim AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/core/sdk:3.0-buster AS build
WORKDIR /src
COPY ["CoreSimulatedDevice/CoreSimulatedDevice.csproj", "CoreSimulatedDevice/"]
RUN dotnet restore "CoreSimulatedDevice/CoreSimulatedDevice.csproj"
COPY . .
WORKDIR "/src/CoreSimulatedDevice"
RUN dotnet build "CoreSimulatedDevice.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "CoreSimulatedDevice.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "CoreSimulatedDevice.dll"]