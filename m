From: Diego Elio =?ISO-8859-1?Q?Petten=F2?= <flameeyes@gmail.com>
Subject: Re: [PATCH] sctp: implement SIOCINQ ioctl() (take 3 bis)
Date: Fri, 15 Oct 2010 16:22:37 +0200
Message-ID: <1287152557.465.24.camel@yamato.local>
References: <20100930.173557.108787840.davem@davemloft.net>
	 <1285926965-5130-1-git-send-email-flameeyes@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256"; protocol="application/pgp-signature"; boundary="=-mHFZpbMbZu3nu9dPPiue"
Cc: linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:62447 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755083Ab0JOOXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 10:23:35 -0400
In-Reply-To: <1285926965-5130-1-git-send-email-flameeyes@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-mHFZpbMbZu3nu9dPPiue
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Il giorno ven, 01/10/2010 alle 11.56 +0200, Diego Elio Petten=C3=B2 ha
scritto:
>=20
>=20
> This simple patch copies the current approach for SIOCINQ ioctl() from
> DCCP
> into SCTP so that the userland code working with SCTP can use a
> similar
> interface across different protocols to know how much space to
> allocate for
> a buffer.=20

Any news on getting this one in? Pretty please? :)

--=20
Diego Elio Petten=C3=B2 =E2=80=94 =E2=80=9CFlameeyes=E2=80=9D
http://blog.flameeyes.eu/

If you found a .asc file in this mail and know not what it is,
it's a GnuPG digital signature: http://www.gnupg.org/


--=-mHFZpbMbZu3nu9dPPiue
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.16 (GNU/Linux)

iQEcBAABCAAGBQJMuGOqAAoJEBqCrVe7WSRDit4H/0eDt0wl126654WuRIyUDUbk
w/y8FYmHRfc/WnigmVBmeGoTD4q6+dz/rkNAeHqIoOUnKH3p548krhIg+fAZLtFu
7Ndg1q65JD632j0QpqskReqnjB6M3V2Qp4xhql0w0WZ2NubWyqYUxiCq3FlsUlwq
07qhiZEPjxaUDo5G3jte9+6xtSw9cH15BRYAjEzM7GZNdt03FOlENpCRSNg0sKld
Ef7S++5uOUyYYiVErsiN5uoSTPtd17+tgxBg0OsC62+vwoJZwbxy3rQMikHQ7yBc
JeiXNGMMqLbt5fupeniVA1THyMB44IIgSHmmshg4IZjBN6qMeHFIoX4uaG+YGI4=
=jDST
-----END PGP SIGNATURE-----

--=-mHFZpbMbZu3nu9dPPiue--

