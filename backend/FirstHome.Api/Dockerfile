# ==========================================
# Stage 1: Build & Publish ASP.NET Core API
# (For builds where Root Directory is set to backend/FirstHome.Api)
# ==========================================
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj and restore dependencies
COPY ["FirstHome.Api.csproj", "./"]
RUN dotnet restore "FirstHome.Api.csproj"

# Copy source code
COPY . .

# Build and publish in Release mode
RUN dotnet publish "FirstHome.Api.csproj" -c Release -o /app/publish /p:UseAppHost=false

# ==========================================
# Stage 2: Production Container Runtime
# ==========================================
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Ensure App_Data folder is created and owned by non-root app user
RUN mkdir -p /app/App_Data && chown -R app:app /app

USER app
COPY --from=build --chown=app:app /app/publish .

# Default ASP.NET Core 8 HTTP port (Render dynamically overrides via PORT env variable)
ENV ASPNETCORE_HTTP_PORTS=8080
EXPOSE 8080

ENTRYPOINT ["dotnet", "FirstHome.Api.dll"]
