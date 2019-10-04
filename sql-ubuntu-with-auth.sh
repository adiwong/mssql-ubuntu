#retrive username and password
mssqlAdmin=$1
mssqlPassword=$2
MSSQL_PID='evaluation'

# Import the public repository GPG keys
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

# Register the Microsoft SQL Server Ubuntu repository:
sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/16.04/mssql-server-2017.list)"
curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | sudo tee /etc/apt/sources.list.d/msprod.list

# Install updates
sudo apt-get update

# The latest version is causing connection issue therefore specifying a version before
sudo apt-get -y install mssql-server=14.0.3192.2-2

# Install the full test search feature
sudo apt-get -y install mssql-server-fts

sleep 2
sudo MSSQL_SA_PASSWORD=$mssqlPassword \
     MSSQL_PID=$MSSQL_PID \
     /opt/mssql/bin/mssql-conf -n setup accept-eula

sudo env ACCEPT_EULA=Y apt-get install -y mssql-tools unixodbc-dev

sudo systemctl stop mssql-server

echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
#sudo MSSQL_SA_PASSWORD="$mssqlPassword" /opt/mssql/bin/mssql-conf set-sa-password
sudo systemctl restart mssql-server

/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P $mssqlPassword -Q "USE MASTER; ALTER LOGIN sa WITH NAME = [$mssqlAdmin];"

# limiting ports
sudo ufw default deny incoming 
sudo ufw allow 22
sudo ufw allow 53
sudo ufw allow 1433
echo "y" | sudo ufw enable
