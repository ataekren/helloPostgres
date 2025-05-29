FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY HelloPostgres.sln ./

COPY HelloPostgres/HelloPostgres.csproj HelloPostgres/
RUN dotnet restore HelloPostgres/HelloPostgres.csproj

COPY . .

WORKDIR /src/HelloPostgres
RUN dotnet build HelloPostgres.csproj -c Release -o /app/build

FROM build AS publish
RUN dotnet publish HelloPostgres.csproj -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

COPY --from=publish /app/publish .

EXPOSE 8080

ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

ENTRYPOINT ["dotnet", "HelloPostgres.dll"] 