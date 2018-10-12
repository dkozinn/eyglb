#!/usr/bin/perl

# Hacked from the sample code at http://www.net-dns.org/docs/Net/DNS/Nameserver.html
# Now writes tracing output to syslog using local0.info
 
use strict;
use warnings;
use Net::DNS::Nameserver;
use Sys::Syslog;
 
sub reply_handler {
    my ($qname, $qclass, $qtype, $peerhost,$query,$conn) = @_;
    my ($rcode, @ans, @auth, @add);
 
# Uncomment the following line to prevent the one-line trace from displaying for each lookup
#    print "Received query from $peerhost to ". $conn->{sockhost}. "\n";

    syslog("info","Received query from $peerhost");

# Uncomment the following line to show the actual query
#    $query->print;

    my ($ttl, $rdata) = (60, $peerhost);
    my $rr = new Net::DNS::RR("$qname $ttl $qclass A $rdata");
    push @ans, $rr;
    $rcode = "NOERROR";
 
    # mark the answer as authoritive (by setting the 'aa' flag
    return ($rcode, \@ans, \@auth, \@add, { aa => 1 });
}
 
$|=1;	# Do not buffer output

openlog("eyglb","pid","local0");
syslog("info", "eyglb ns starting");

# Set the LocalAddr to whatever your local network interface is.
my $ns = new Net::DNS::Nameserver(
    LocalAddr    => ['192.168.0.42' ],
    LocalPort    => 53,
    ReplyHandler => \&reply_handler,
    Verbose      => 0
    ) || die "couldn't create nameserver object\n";
 
$ns->main_loop;
