From: Jeff Sipek <jeffpc@optonline.net>
Subject: Re: [PATCH - RFC] [1/5] 64-bit network statistics - generic net
Date: Sat, 05 Jul 2003 16:59:05 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <200307051700.32533.jeffpc@optonline.net>
References: <E19YtAq-0006Xf-00@calista.inka.de>
 <200307051637.52252.jeffpc@optonline.net> <3F0737D1.5090109@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 7BIT
Cc: Bernd Eckenfels <ecki@calista.eckenfels.6bone.ka-ip.net>,
	linux-kernel@vger.kernel.org, Andrew Morton <akpm@digeo.com>,
	Dave Jones <davej@codemonkey.org.uk>,
	Linus Torvalds <torvalds@osdl.org>, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
In-reply-to: <3F0737D1.5090109@pobox.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Content-description: clearsigned data
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Saturday 05 July 2003 16:40, Jeff Garzik wrote:
> The net stats are already unsigned long internally.
>
> 64-bit case is handled quite nicely today, thanks :)

I wonder why jiffies are not unsigned long...the 64-bit case would have been 
handled quite nicely too... :-)

> I'm such a 64-bit bigot that "buy a 64-bit computer" is a solution I
> commonly suggest, and it seems to fit well here, too.

I wish I had the resources to get one... :-(

The thing is that x86 is here to stay for quite some time. Even if 64-bit 
processors take over the market, you will have so many "old" computers that 
can:

- - be thrown out
- - donated to some institution
- - converted to routers, and other "embedded" systems

Plus, they will be dirt cheap.

> 	Jeff, wondering if Intel will bother to compete w/ Athlon64

Intel screwed up with Itanium, if it had "legacy" support, they would have 
been better off...

Jeff.

- -- 
Defenestration n. (formal or joc.):
  The act of removing Windows from your computer in disgust, usually followed
  by the installation of Linux or some other Unix-like operating system.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQE/BzwdwFP0+seVj/4RAoUZAJ0dptf9cB60dDUQHU61zg6lO5CXSQCgqHWU
8VvyepQwEdTsNFYyozGedAY=
=OsNH
-----END PGP SIGNATURE-----
