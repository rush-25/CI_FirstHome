# ==========================================
# Stage 1: Build & Publish ASP.NET Core API
# ==========================================
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj and restore dependencies first (layer caching)
COPY ["backend/FirstHome.Api/FirstHome.Api.csproj", "backend/FirstHome.Api/"]
RUN dotnet restore "backend/FirstHome.Api/FirstHome.Api.csproj"

# Copy the rest of the backend source code
COPY backend/FirstHome.Api/ backend/FirstHome.Api/

# Build and publish in Release mode
WORKDIR "/src/backend/FirstHome.Api"
RUN dotnet publish "FirstHome.Api.csproj" -c Release -o /app/publish /p:UseAppHost=false

# ==========================================
# Stage 2: Production Container Runtime
# ==========================================
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Ensure App_Data folder is created and owned by the non-root app user
RUN mkdir -p /app/App_Data && chown -R app:app /app

USER app
COPY --from=build --chown=app:app /app/publish .

# Default ASP.NET Core 8 HTTP port (Render dynamically overrides via PORT env variable)
ENV ASPNETCORE_HTTP_PORTS=8080
EXPOSE 8080

ENTRYPOINT ["dotnet", "FirstHome.Api.dll"]
