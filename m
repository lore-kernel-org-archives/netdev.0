From: Jeff Sipek <jeffpc@optonline.net>
Subject: Re: [PATCH 2.6] watch64: generic variable monitoring system
Date: Sun, 05 Sep 2004 12:19:34 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <200409051219.47590.jeffpc@optonline.net>
References: <200409031307.01240.jeffpc@optonline.net>
 <200409031744.32970.jeffpc@optonline.net>
 <1094303999.1633.116.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 7BIT
Cc: Stephen Hemminger <shemminger@osdl.org>,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S266850AbUIEQTw@vger.kernel.org>
In-reply-to: <1094303999.1633.116.camel@jzny.localdomain>
To: hadi@cyberus.ca
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Saturday 04 September 2004 09:19, jamal wrote:
> I have a feeling this was discussed somewhere(other than netdev) and i
> missed it. Why isnt this watch64 being done in user space?

There was a discussion about 64-bit network statistics about a year ago on 
lkml.

watch64 is a generic so that anyone in the kernel can use it.

Jeff.

- -- 
Mankind invented the atomic bomb, but no mouse would ever construct a 
mousetrap.
  - Albert Einstein



-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBOzybwFP0+seVj/4RArmhAKC3ddX4ZGoAMQKxGplXqqbER9BBMQCfencW
wDt06dC8MifG9NU3xWx0ULo=
=z9kC
-----END PGP SIGNATURE-----
