#!/bin/bash


#CREATES SCRIPT

#Create files
mkdir /ipc_test
cd /ipc_test
touch shmw.pl shmr.pl
chmod -R 777 /ipc_test

#Add content to shmr.pl
cat << 'EOF' > /ipc_test/shmr.pl
#!/usr/bin/perl

# Assume this file name is reader.pl

$key = 12345;
$size = 80;

# Identify the shared memory segment
$id = shmget( $key, $size, 0777 ) or die "Can't shmget: $!";

# Read its contents itno a string
shmread($id, $var, 0, $size) or die "Can't shmread: $!";

print $var;
EOF

#Add content to shmw.pl
cat << 'EOF' > /ipc_test/shmw.pl
#!/usr/bin/perl

# Assume this file name is writer.pl

use IPC::SysV;

#use these next two lines if the previous use fails.
eval 'sub IPC_CREAT {0001000}' unless defined &IPC_CREAT;
eval 'sub IPC_RMID {0}'        unless defined &IPC_RMID;

$key  = 12345;
$size = 80;
$message = "Shared memory message\n";

# Create the shared memory segment

$id = shmget($key, $size, &IPC_CREAT | 0777 ) or die "Can't shmget: $!";

# Place a string in itl
shmwrite( $id, $message, 0, 80 ) or die "Can't shmwrite: $!";


sleep 120;

# Delete it;

shmctl( $id, &IPC_RMID, 0 ) or die "Can't shmctl: $! ";

EOF
