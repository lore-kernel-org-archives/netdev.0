From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: 2.6.11 kernel, PPC, and IPv6
Date: Tue, 19 Apr 2005 02:14:41 +0900 (JST)
Message-ID: <20050419.021441.50994203.yoshfuji@linux-ipv6.org>
References: <19EE6EC66973A5408FBE4CB7772F6F0A0289942D@ltnmail.xyplex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: pbellino@mrv.com
In-Reply-To: <19EE6EC66973A5408FBE4CB7772F6F0A0289942D@ltnmail.xyplex.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <19EE6EC66973A5408FBE4CB7772F6F0A0289942D@ltnmail.xyplex.com> (at Mon, 18 Apr 2005 12:27:31 -0400), "Bellino, Phil" <pbellino@mrv.com> says:

> > Is there anyone out there who is using(or attempting to use) IPv6 with
> > PowerPC  and a 2.6.11 kernel with whom I could email directly with some
> > specific questions?
> > 
> > One of my questions is at boot time, my eth0 device does not have it's
> > link-local address.  I must issue an "ifconfig eth0 down" and then an
> > "ifconfig eth0 up" to get this work work.
> > 
> > Also, it does not auto-configure the info for a link-global prefix/address
> > that is provided by the router announcements.

2.6.12-rcs seem to work fine on my x86 and ultrasparc at least.
I'm trying to build on my ppc as well.

--yoshfuji
