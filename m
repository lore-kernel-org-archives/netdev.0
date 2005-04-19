From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@wide.ad.jp>
Subject: Re: 2.6.11 kernel, PPC, and IPv6
Date: Tue, 19 Apr 2005 10:15:01 +0900 (JST)
Message-ID: <20050419.101501.36911974.yoshfuji@wide.ad.jp>
References: <19EE6EC66973A5408FBE4CB7772F6F0A0289942D@ltnmail.xyplex.com>
	<20050419.021441.50994203.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: pbellino@mrv.com
In-Reply-To: <20050419.021441.50994203.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20050419.021441.50994203.yoshfuji@linux-ipv6.org> (at Tue, 19 Apr 2005 02:14:41 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> In article <19EE6EC66973A5408FBE4CB7772F6F0A0289942D@ltnmail.xyplex.com> (at Mon, 18 Apr 2005 12:27:31 -0400), "Bellino, Phil" <pbellino@mrv.com> says:
:
> > > One of my questions is at boot time, my eth0 device does not have it's
> > > link-local address.  I must issue an "ifconfig eth0 down" and then an
> > > "ifconfig eth0 up" to get this work work.
> > > 
> > > Also, it does not auto-configure the info for a link-global prefix/address
> > > that is provided by the router announcements.
> 
> 2.6.12-rcs seem to work fine on my x86 and ultrasparc at least.
> I'm trying to build on my ppc as well.

It seems to work fine on my ppc.

--yoshfuji
