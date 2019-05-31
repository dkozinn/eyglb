# EYGLB

## Synopsis
This is a perl program that acts similar to a DNS server except that no matter what you ask it for, it always returns the IP address of the client that asked for the information as an **A** record. This is a mildly hacked version of the example program shown at  http://www.net-dns.org/docs/Net/DNS/Nameserver.html. There is probably a better way to do this, but this was very quick to put together.

## Requirements
Needs the `Net::DNS::Nameserver` package and `Sys::Syslog` if you're going to use syslog for output. (If not, see details under **Use** below).

## Preparation
The most important thing is to edit the block of code just before the end:

```perl
my $ns = new Net::DNS::Nameserver(
    LocalAddr    => ['192.168.0.42' ],
    LocalPort    => 53,
    ReplyHandler => \&reply_handler,
    Verbose      => 0
    ) || die "couldn't create nameserver object\n";
```

Change **LocalAddr** to whatever the IP address of your server is. (You might be able to remove this parameter entirely; the documentation says that it should default to **INADDR_ANY** but the server code croaks when I left it at that. If you're going to run this as a real DNS server, leave **LocalPort** at 53, otherwise change it to something else, like 5353. Note that running on 53 (or anything below 1024) requires root privs.

One of the hacks I made was to send some very basic output to syslog (which saves me the trouble of even having to put in a timestamp). If you are using syslog you can modify the `opensyslog()` statement as necessary. The default is set to use **eyglb** as the process name, log the pid, and use `local0` as the facility code. See http://perldoc.perl.org/Sys/Syslog.html for more details about this. If you are not using syslog, you'll want to comment out or remove the `use Sys::Syslog;` line as well as the `openlog()` and `syslog()` statements

# Use
This will need to run as root since it opens TCP & UDP 53.  For test purposes, you can just invoke at the command line. You may want to uncomment the couple of lines that print useful information to **STDOUT** with the **print** statements. To run as a server, the easiest way is just to invoke with `nohup` and throw it in the background. It should be pretty obvious that this isn't intended to be terribly robust, and if it crashes for whatever reason it doesn't try to recover or even notify anyone.

If you wish to run this a service on a system that supports systemd, copy **ns.service** to /lib/systemd/system and start it using 
```
sudo systemctl start ns.service
```
If it's working properly for you, you can then enable it to start automatically at boot with
```
sudo systemctl start ns.service
```
