# This script is intended for migration of v5.3 to v5.4 for Globus
# Guide is available here: https://docs.globus.org/globus-connect-server/v5.4/migration-guide/

# Disable globus-gridftp-server
sudo systemctl stop globus-gridftp-server

# Install new software
sudo apt remove globus-connect-server53
sudo apt install globus-connect-server54

# This dependency was note deleted. This should make it work
sudo apt remove libglobus-dsi-rest0

# If still an issue consider upgrade to gridftp
# apt-get upgrade globus-gridftp-server6 -f

# Save copy of v5.3 configurations (optional)
cp /etc/globus-connect-server.conf /etc/globus-connect-server.conf.v5.3
for c_file in /etc/globus/*.conf
do
  cp $c_file $c_file.v5.3
done

# Migrate the endpoint
sudo globus-connect-server endpoint migrate53 --owner chunly@arizona.edu --ip-address #IP_ADDRESS#

# Note will need to update mapped collections
# See: https://docs.globus.org/globus-connect-server/v5.4/migration-guide/#update_collections
