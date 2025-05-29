# Use the official .NET 8.0 SDK image for building
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy the solution file
COPY HelloPostgres.sln ./

# Copy the project file and restore dependencies
COPY HelloPostgres/HelloPostgres.csproj HelloPostgres/
RUN dotnet restore HelloPostgres/HelloPostgres.csproj

# Copy the rest of the application code
COPY . .

# Build the application
WORKDIR /src/HelloPostgres
RUN dotnet build HelloPostgres.csproj -c Release -o /app/build

# Publish the application
FROM build AS publish
RUN dotnet publish HelloPostgres.csproj -c Release -o /app/publish

# Use the official ASP.NET Core runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Copy the published application
COPY --from=publish /app/publish .

# Expose the port that the application runs on
EXPOSE 8080

# Set environment variables
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

# Define the entry point
ENTRYPOINT ["dotnet", "HelloPostgres.dll"] 