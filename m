From: Harald Welte <laforge@netfilter.org>
Subject: Re: Problem using fwmarks as routing key: "MASQUERADE: Route sent us somewhere else."
Date: Tue, 27 Jan 2004 02:51:52 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040127015152.GP19250@sunbeam.de.gnumonks.org>
References: <001c01c3e043$93583cd0$1684188d@Kiste>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="FcSpk3Icpd/Pbul4"
Cc: netfilter@lists.netfilter.org, netdev@oss.sgi.com,
        Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thhoep <thhoep@gmx.de>
Content-Disposition: inline
In-Reply-To: <001c01c3e043$93583cd0$1684188d@Kiste>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--FcSpk3Icpd/Pbul4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jan 21, 2004 at 06:25:22PM +0100, Thhoep wrote:
> hi,
>=20
> my aim: to divide 100 hosts upon 6 masqueraded adsl connections to the
> internet using a linux router runnig a debian woody.
>=20
> the problem: really strange behaviour of the routing/masquerading combo,
> that changes with every tried kernel version. (described below)
>=20
> presumption: some version mismatch or a bug in the kernel routing code,
> which needs a bugfix that till now is unknown to me

Please read the recent archives of the netdev list with regard to
"Rusty's brain broke".  Also see=20
https://bugzilla.netfilter.org/cgi-bin/bugzilla/show_bug.cgi?id=3D144

Alexey heavily argued against us reverting that change, however :(

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--FcSpk3Icpd/Pbul4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFAFcQ4XaXGVTD0i/8RAsKqAJ0Q9QW37doao1sqR2PoEhUH+fVqyQCgp0vM
jwRf5NBu0ZGXvns9H02A6f4=
=/1Gy
-----END PGP SIGNATURE-----

--FcSpk3Icpd/Pbul4--
