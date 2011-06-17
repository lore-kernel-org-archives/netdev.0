From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH net-next] net: remove mm.h inclusion from netdevice.h
Date: Fri, 17 Jun 2011 13:19:37 +1000
Message-ID: <20110617131937.63c71cb6.sfr@canb.auug.org.au>
References: <20110616210134.GA18026@p183.telecom.by>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__17_Jun_2011_13_19_37_+1000_1v=4LmR4gIeb+V=b"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fujita.tomonori@lab.ntt.co.jp,
	linux-arch@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20110616210134.GA18026@p183.telecom.by>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__17_Jun_2011_13_19_37_+1000_1v=4LmR4gIeb+V=b
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Alexy,

On Fri, 17 Jun 2011 00:01:34 +0300 Alexey Dobriyan <adobriyan@gmail.com> wr=
ote:
>
> Remove linux/mm.h inclusion from netdevice.h -- it's unused (I've checked=
 manually).

Have you tried building this with STAGING enabled?  The fallout for
STAGING from the removal of linux/interrupt.h is still not sorted out.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__17_Jun_2011_13_19_37_+1000_1v=4LmR4gIeb+V=b
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJN+sfJAAoJEDMEi1NhKgbs+AgH/jYsT2sY6W6QmlkD8CAleZP5
EM2YDrgZHNG8sePYbubGvJsIsnRihoWiL+eK97fud7ED2CBHysYu4Dn3du0amj6o
33MAT8WiKW211OvhAV1TthlPiRhwDRmi6eXMWh5fzYdhbIWE/8N0+VUYFyoqyEDc
1cvKjSckXY+iIYKnpTyBvpPf/f6YCuE/7RdYRGaNhCyC77VlJ1izgbE9TI+Eo91K
0uGxKOM+6WPrDlEmZpGxqPnPlRWFwuVRxCeksRJM2oYNjS+vkeZO5SywnDJi8e0l
acn5GfS97TQfbJ8H6XnVvG5LDt51+ilAYaK6bDOr1bHZrVZmVTbxatq3DMrTq0c=
=09qq
-----END PGP SIGNATURE-----

--Signature=_Fri__17_Jun_2011_13_19_37_+1000_1v=4LmR4gIeb+V=b--
