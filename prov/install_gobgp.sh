# go version to install
export GO_VERSION=1.11.10

# set envvars for go
cat << EOF > /etc/profile.d/golang.sh
export GOROOT=/usr/local/go
export GOPATH=/usr/local/opt/gopath
export PATH=\$GOROOT/bin:\$PATH
EOF

source /etc/profile.d/golang.sh

# install go
mkdir -p $GOPATH
mkdir -p $GOROOT
cd $GOROOT/..
wget https://storage.googleapis.com/golang/go${GO_VERSION}.linux-amd64.tar.gz > /dev/null 2>&1
tar zxf go${GO_VERSION}.linux-amd64.tar.gz

# install git (required to run go get)
apt-get update
apt-get install -y git

# install gobgp and gobgpd
git clone https://github.com/osrg/gobgp.git
cd gobgp
export GO111MODULE=on
go mod download
go build -v -o ./bin/gobgp ./cmd/gobgp/
go build -v -o ./bin/gobgpd ./cmd/gobgpd/
#go get -v github.com/osrg/gobgp/gobgpd
#go get -v github.com/osrg/gobgp/gobgp
cd $GOROOT/..
# install bash completions for gobgp command
cp ./gobgp/tools/completion/*.bash /etc/bash_completion.d/


id gobgpd || useradd -r gobgpd
cp ./gobgp/bin/* /usr/local/sbin
mkdir -p /etc/gobgp
cp /vagrant/prov/gobgpd.service /etc/systemd/system
systemctl daemon-reload
