From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH] Add C99 initializers to ip_conntrack_standalone.c
Date: Fri, 20 Feb 2004 23:48:46 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040220224846.GX4797@sunbeam.de.gnumonks.org>
References: <20040219001343.GB9704@artsapartment.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="2RPSo2VWgDbGU+zh"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Art Haas <ahaas@airmail.net>
Content-Disposition: inline
In-Reply-To: <20040219001343.GB9704@artsapartment.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--2RPSo2VWgDbGU+zh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Feb 18, 2004 at 06:13:43PM -0600, Art Haas wrote:
> Hi.
>=20
> Here's a patch that converts this file to use C99 initializers. The code
> is much easier to read after the conversion, I believe. I have
> recompiled the file with the changes successfully.

Thanks, I integrated your patch with some clashing changes we had in our
set of pending patches and submitted it to davem a couple of hours ago.

> Art Haas
--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--2RPSo2VWgDbGU+zh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFANo7OXaXGVTD0i/8RAiHwAJ9ofTrjyFOdbHywKbm3ViQ+KveSsACcD6Zr
ddBD779EEyhanW84d7pOe0Y=
=8Qu+
-----END PGP SIGNATURE-----

--2RPSo2VWgDbGU+zh--
