From: "David S. Miller" <davem@redhat.com>
Subject: Todays net-2.6 update
Date: Fri, 20 Aug 2004 14:54:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040820145454.36484216.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="Multipart=_Fri__20_Aug_2004_14_54_54_-0700_SQ5qVP4sJKd_/hzR"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--Multipart=_Fri__20_Aug_2004_14_54_54_-0700_SQ5qVP4sJKd_/hzR
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit


At the usual spots:

	bk://kernel.bkbits.net/davem/net-2.6
	ftp.kernel.org:/pub/linux/kernel/people/davem/net-2.6.9-4.gz

And relative diff attached.  This one is a little large.

Main things:

1) inetdev RCU locking

2) Kill IP_ROUTE_NAT code.  It's been broken from mid-2.5.x
   and if someone is interested in making it work again
   they can easily resurrect the code.

3) Enhanced net_random() from Stephen Hemminger.

4) Several routing and device handling fixes in ipv6
   from Yoshifuji-san.

Enjoy.

--Multipart=_Fri__20_Aug_2004_14_54_54_-0700_SQ5qVP4sJKd_/hzR--
