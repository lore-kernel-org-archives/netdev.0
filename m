From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH 2.6] Add NAPI support to sungem.c
Date: Wed, 15 Sep 2004 21:37:18 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040915193718.GE2678@sunbeam.de.gnumonks.org>
References: <20040914153537.GE8434@sunbeam.de.gnumonks.org> <20040914124315.716e9c68.davem@davemloft.net> <20040914200238.GM8434@sunbeam.de.gnumonks.org> <5cac192f04091422506d13c530@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="//IivP0gvsAy3Can"
Cc: netdev@oss.sgi.com, linuxppc-dev@lists.linuxppc.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Lemoine <eric.lemoine@gmail.com>
Content-Disposition: inline
In-Reply-To: <5cac192f04091422506d13c530@mail.gmail.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--//IivP0gvsAy3Can
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 15, 2004 at 07:50:28AM +0200, Eric Lemoine wrote:
> Your patch has the netpoll bits while current BK does not.

Well, it's straight forward to merge them into BK...

> PS: If you happened to experiment with the NAPIfied SunGEM driver on
> your setup, could you please share the data. Thx.

I didn't do any measurements so far... I only know that my Powerbook
doesn't stop responding anymore when I flood it with pktgen ;) =20

> Eric

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--//IivP0gvsAy3Can
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBSJnuXaXGVTD0i/8RAnSqAJwJ3IxGdAD9xL1VTHwYw+F1E+Pu0wCfRpS+
mZaQizF4BVK6pV0jCIoHiH4=
=cRJ/
-----END PGP SIGNATURE-----

--//IivP0gvsAy3Can--
