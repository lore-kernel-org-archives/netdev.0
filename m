From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: 82540EM very slow on 2.6.0-test[45]
Date: Thu, 11 Sep 2003 14:40:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E010124F030@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: <rwhron@earthlink.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> I tried 4 Solaris servers.  2 had forced full duplex
> and 100 Mbps.  Those are slow.  2 other Solaris servers
> on the same LAN as the "slow" Solaris servers are fast.
> These "fast" servers are using default settings (which
> should also be 100 Mbps full-duplex).

Maybe someone else on the list has some suggestions?  I think we're
troubleshooting your network now.

Is it just ftp that's slow?  What's in the path between the Linux and
the "slow" Solaris server?  Can you shorten the path?  What happens if
you don't force 100/full on the "slow" Solaris server?

-scott
