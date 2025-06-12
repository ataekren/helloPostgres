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

RUN apt-get update && apt-get install -y openssh-server && rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd
RUN echo 'root:Docker!' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
RUN sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config

COPY --from=publish /app/publish .

RUN echo '#!/bin/bash\n\
service ssh start\n\
dotnet HelloPostgres.dll' > /app/start.sh && chmod +x /app/start.sh

EXPOSE 8080 2222

ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

ENTRYPOINT ["/app/start.sh"]