From: Jeff Sipek <jeffpc@optonline.net>
Subject: Re: [PATCH/RFC 2.6] NET: 64-bit network statistics
Date: Fri, 03 Sep 2004 13:24:28 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409031324.36252.jeffpc@optonline.net>
References: <200409031307.01240.jeffpc@optonline.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 7BIT
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-reply-to: <200409031307.01240.jeffpc@optonline.net>
To: linux-kernel@vger.kernel.org
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Friday 03 September 2004 13:06, josef Jeff Sipek wrote:
> I've created a patch that monitors changes to the network statistics
> variables and keeps internal 64-bit counter. I decided to split it into two
> parts (patches are to follow in next emails):
>  1) generic variable monitoring system (watch64)
>  2) network statistics specific patch (64network)

Btw, both of these patches apply cleanly against 2.6.9-rc1-bk10.

Jeff.

- -- 
bad pun of the week: the formula 1 control computer suffered from a race 
condition
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBOKjQwFP0+seVj/4RApg/AKDEFSTVOMSvVh9zVU65o/P6ZcfBxgCffeId
QddOVsR+uHdkV2D4/U8QVO4=
=jQIT
-----END PGP SIGNATURE-----
