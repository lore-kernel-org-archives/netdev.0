From: crochu nicolas <nicolas.crochu@sgam.com>
Subject: Re: [update] 2.6.4-rc2 - Realtek 8169 patches
Date: Fri, 12 Mar 2004 14:40:57 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1079098857.2791.10.camel@localhost>
References: <20040307023748.A7829@electric-eye.fr.zoreil.com>
	 <1078822878.2408.8.camel@pinacola>
	 <20040311193937.A14638@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-UqbdjlJhQ5H9sQYKNmrD"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040311193937.A14638@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-UqbdjlJhQ5H9sQYKNmrD
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

Le jeu 11/03/2004 =E0 19:39, Francois Romieu a =E9crit :
> crochu nicolas <nicolas.crochu@sgam.com> :
> > If i apply only these patch, everything goes fine
> [...]
> Did you stress the driver, say (rsync), ping -f -s 8, ttcp ?
> --
> Ueimor

I tested with unison, ping -f -s 8
as did a friend with the same hardware.

My kernel : 2.6.3 + patched driver ( except the last 3 patch )
My friend : a stock 2.6.4-mm1 kernel.

everything goes fine.

my friend told me something about the io/schedulers as a source=20
of instability .. i'm investigatng.

C.Nicolas.



--=-UqbdjlJhQ5H9sQYKNmrD
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: Ceci est une partie de message
	=?ISO-8859-1?Q?num=E9riquement?= =?ISO-8859-1?Q?_sign=E9e?=

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQBAUb3pxsSeKWK8V4QRApt9AJ4hVhUEko5pOvq7Kugi7V286pN25ACcDriX
FZpegsGLQ//UOzabAH5ACoo=
=2YOV
-----END PGP SIGNATURE-----

--=-UqbdjlJhQ5H9sQYKNmrD--
