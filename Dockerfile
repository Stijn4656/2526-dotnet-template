# Build stage: full .NET 9 SDK, compiles the server and the Blazor WebAssembly client
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src
COPY . .
# Publishing Rise.Server also publishes the referenced Blazor client into wwwroot
RUN dotnet publish src/Rise.Server/Rise.Server.csproj -c Release -o /app

# Runtime stage: only the ASP.NET runtime, much smaller than the SDK image
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
WORKDIR /app
COPY --from=build /app .
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
ENTRYPOINT ["dotnet", "Rise.Server.dll"]
