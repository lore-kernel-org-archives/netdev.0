From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: 2.6.10-bk4 ip_conntrack oops fix
Date: Sun, 02 Jan 2005 11:05:32 +0100
Message-ID: <1104660332.3821.40.camel@tux.rsn.bth.se>
References: <Pine.LNX.4.58.0501020611430.12403@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-t7qNmEHVwCYZzqHnTZvU"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matthew J Galgoci <mgalgoci@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <Pine.LNX.4.58.0501020611430.12403@parcelfarce.linux.theplanet.co.uk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-t7qNmEHVwCYZzqHnTZvU
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2005-01-02 at 06:12 +0000, Matthew J Galgoci wrote:
> I stumbled onto an annoying oops in 2.6.10-bk4.
>=20
> Here is how to cause the oops.
>=20
> load ip_conntrack
> remove ip_conntrack
> ls /proc/net/stat
> boom

Thanks for the fix, a patch for this has already been submitted.
Hopefully it'll make it's way into the tree soon, The hollidays and
vacations is making the process a bit sluggish at the moment.

--=20
/Martin

--=-t7qNmEHVwCYZzqHnTZvU
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQBB18dsWm2vlfa207ERAp+UAKCjWidLHkboST3L0uLOp6zGHZ0wFgCfW0g3
19ViKWGchnRiP9dwpuLiOrU=
=RPkS
-----END PGP SIGNATURE-----

--=-t7qNmEHVwCYZzqHnTZvU--
