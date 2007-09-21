From: Valdis.Kletnieks@vt.edu
Subject: Re: [PATCH 1/2] bnx2: factor out gzip unpacker
Date: Fri, 21 Sep 2007 14:36:52 -0400
Message-ID: <15775.1190399812@turing-police.cc.vt.edu>
References: <200709211201.24475.vda.linux@googlemail.com> <200709211803.55554.vda.linux@googlemail.com> <20070921.104912.41646795.davem@davemloft.net>
            <200709211905.23946.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1190399812_2847P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jeff@garzik.org,
	mchan@broadcom.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Denys Vlasenko <vda.linux@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from turing-police.cc.vt.edu ([128.173.14.107]:38182 "EHLO
	turing-police.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753097AbXIUShC (ORCPT
	<RFC822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 14:37:02 -0400
In-Reply-To: Your message of "Fri, 21 Sep 2007 19:05:23 BST."
             <200709211905.23946.vda.linux@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1190399812_2847P
Content-Type: text/plain; charset=us-ascii

On Fri, 21 Sep 2007 19:05:23 BST, Denys Vlasenko said:

> I plan to use gzip compression on following drivers' firmware,
> if patches will be accepted:
> 
>    text    data     bss     dec     hex filename
>   17653  109968     240  127861   1f375 drivers/net/acenic.o
>    6628  120448       4  127080   1f068 drivers/net/dgrs.o
>          ^^^^^^

Should this be redone to use the existing firmware loading framework to
load the firmware instead?

--==_Exmh_1190399812_2847P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFG9A9EcC3lWbTT17ARAiYhAKCqI4hIp4QmE5WjzMk/i9i1SwxEwACfZMl3
PB4PUEVlBwH+6zqjLgMX6yI=
=tT+I
-----END PGP SIGNATURE-----

--==_Exmh_1190399812_2847P--
