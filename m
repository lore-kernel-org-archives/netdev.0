From: Lars Marowsky-Bree <lmb@suse.de>
Subject: Re: multiple unicast mac address (was Re: netdev_ops retraction)
Date: Thu, 31 Jul 2003 15:27:45 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030731132745.GQ29577@marowsky-bree.de>
References: <20030730184416.GI22222@parcelfarce.linux.theplanet.co.uk> <2147483647.1059659359@fozzy.rossfell.co.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="DXIF1lRUlMsbZ3S1"
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Payne <rickp@rossfell.co.uk>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <2147483647.1059659359@fozzy.rossfell.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--DXIF1lRUlMsbZ3S1
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 2003-07-31T13:49:19,
   Rick Payne <rickp@rossfell.co.uk> said:

> Some ethernet cards seem to support this and don't care what MAC addresse=
s=20
> get put in the multicast list - and I've used that technique before (on=
=20
> cards such as the eepro100 for instance). Others may have a different, no=
t=20
> currently used method to set multiple unicast MAC addresses. Finally, as =
a=20
> worst last case - a card could go into promiscuous mode and filter in=20
> software.
>=20
> Should I just start on a patch and submit it here for comment?

Please do.


Sincerely,
    Lars Marowsky-Br=E9e <lmb@suse.de>

--=20
SuSE Labs - Research & Development, SuSE Linux AG
 =20
"If anything can go wrong, it will." "Chance favors the prepared (mind)."
  -- Capt. Edward A. Murphy            -- Louis Pasteur

--DXIF1lRUlMsbZ3S1
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.7 (GNU/Linux)

iD8DBQE/KRlQudf3XQV4S2cRArrwAJ40JywXivobQaFGH0tQ6+4ry25/+QCggzHr
zk/k2btBhP8sMaGWkLyWUR0=
=F4R8
-----END PGP SIGNATURE-----

--DXIF1lRUlMsbZ3S1--
