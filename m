From: Jeff Sipek <jeffpc@optonline.net>
Subject: Re: [PATCH 2.6] watch64: generic variable monitoring system
Date: Sun, 12 Sep 2004 11:53:44 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <200409121153.52047.jeffpc@optonline.net>
References: <200409031307.01240.jeffpc@optonline.net>
 <200409051219.47590.jeffpc@optonline.net>
 <1094460391.1151.26.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 7BIT
Cc: Stephen Hemminger <shemminger@osdl.org>,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S268117AbUILPy3@vger.kernel.org>
In-reply-to: <1094460391.1151.26.camel@jzny.localdomain>
To: hadi@cyberus.ca
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Sorry, I missed your email.

On Tuesday 07 September 2004 06:18, jamal wrote:
> On Sun, 2004-09-05 at 12:19, Jeff Sipek wrote:
> > There was a discussion about 64-bit network statistics about a year ago
> > on lkml.
>
> Sorry unsubscribed from lkml since summer of '94. [net related
> discussions should really happen on netdev].

netdev was CC'd during this whole discussion.

> > watch64 is a generic so that anyone in the kernel can use it.
>
> Ok - so why does this have to be in the kernel?

I think it is convenient to have the 64 bit net stats reported by the kernel.

Jeff.

- -- 
My public GPG key can be found at
http://shells.gnugeneration.com/~jeffpc/gpg/public-0xC7958FFE.txt
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBRHENwFP0+seVj/4RAuzcAKCdBAooPae8pTaMEHbWmVDKAO7C5ACeLi21
cen/Ag4bH5Dm9xkQiXj+d0Q=
=BrV+
-----END PGP SIGNATURE-----
