From: bert hubert <ahu@ds9a.nl>
Subject: ipsec, nat-t, iproute2?
Date: Fri, 30 Jul 2004 19:07:26 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040730170726.GA5144@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi people,

I'm once again trying to get a hang of the state of ipsec in linux, and I
have some questions.

1) One can configure ipsec over netlink (XFRM_USER), is this the preferred
interface? Is it documented somehwere, or is there some source which uses
this interface? Alternatively, is PFKEY considered deprecated?

2) I hear people are working on iproute so it can use XFRM_USER, is this
code available somewhere?

3) NAT-Traversal, how does one set this up either using setkey,
iproute2+stuff, or XFRM_USER? Is it supposed to work right now?
Is NAT-T 'UDP_ENCAP_ESPINUDP'?

Thanks. What I'll figure out from these questions I'll document.

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
