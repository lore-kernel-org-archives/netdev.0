From: Valdis.Kletnieks@vt.edu
Subject: Re: Bug somewhere in crypto or ipsec stuff
Date: Wed, 29 Oct 2003 23:33:03 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310300433.h9U4X49X010982@turing-police.cc.vt.edu>
References: <20031030.121732.12858700.yoshfuji@linux-ipv6.org> <Xine.LNX.4.44.0310292221320.23405-100000@thoron.boston.redhat.com>
            <20031030.124124.26191552.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_-1784525846P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: Your message of "Thu, 30 Oct 2003 12:41:24 +0900."
             <20031030.124124.26191552.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--==_Exmh_-1784525846P
Content-Type: text/plain; charset=us-ascii

On Thu, 30 Oct 2003 12:41:24 +0900, YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= said:

> Well, people may want to get just any algorithm.
> In such case,
>  - crypto allows name == NULL, and return any algorithm
>    (for example, an algorithm that we see first.)

This could be embarasssing if somebody happened to have the rot13 debugging
algorithm loaded.....

--==_Exmh_-1784525846P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQE/oJR/cC3lWbTT17ARAlPEAKCjUMEEZAQSkrLUBgHwAelA+d/xOQCdF76k
qjzL1sHOGwz+5yOIN0nGoNo=
=x8w/
-----END PGP SIGNATURE-----

--==_Exmh_-1784525846P--
