From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: janz-ican3: fix type missmatch in assignment
Date: Mon, 02 Feb 2015 10:25:08 +0100
Message-ID: <54CF4274.1040600@pengutronix.de>
References: <1422779674-27823-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="S1Xjeh9jebSpqPcPKhTKcQdPR1r5b24sv"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Nicholas Mc Guire <der.herr@hofr.at>
To: Nicholas Mc Guire <hofrat@osadl.org>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1422779674-27823-1-git-send-email-hofrat@osadl.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--S1Xjeh9jebSpqPcPKhTKcQdPR1r5b24sv
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 02/01/2015 09:34 AM, Nicholas Mc Guire wrote:
> From: Nicholas Mc Guire <der.herr@hofr.at>
>=20
> return type of wait_for_completion_timeout is unsigned long not int, th=
is
> patch removes the type missmatch by moving the call into the condition.=

>=20
> Signed-off-by: Nicholas Mc Guire <der.herr@hofr.at>

Thanks, applied to can-next.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--S1Xjeh9jebSpqPcPKhTKcQdPR1r5b24sv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJUz0J4AAoJECte4hHFiupUgIkQAJ+Eiupy7xI7fwmMo0YfFOwu
OOYwpJo5+JZ1BayZ6LHHwiiGz0+o5Q4OYlw4XYdQJ7AnWTdP7ECEbCPUmX3Fm5eR
NtYenJtXripb/Eogt6/W75Bo9G8N/S+uT1WvkW9hy3NtFBhjxhldoyVRnLHlJN/X
ABIWB/Kw/6gAmkKDQMWj+BhUGg2P5T8tWugkHnbnasy9TN/fX6/1HvdPPYZ29Psm
uESrPvfDDA2IfUtpxuDBOxpowqBWdlWouzsZ+9qRV7t32VAVC9Xq1YV+BsQMw8uU
m8Hvx8LZcKoZNc08u0m1bT5JOm5mE+3SOnFucPnVzX0EtR1ekJbqsPGWqK50mkB7
NTToMWu3xIKsINZhy1rVB28syn6yzHIG7dkNyYwXLblEgt1Q4v1m6GufSbcKbiSC
WWDm0GxHNdpEkuJ1gywFtY+FbJXqUbNjNVaVb6BMdNtVXDGbWi/fIImQTGzMoGyS
DCEXOBugkKNEbi0kkYnb0WrBGv7YE1kZsnVFHaYc2Arwjrz19jKmZS/lDVJuyOun
Xx3j2IUtVoT5z0uXztuxxbhBcihGw+mbmV/BoMvO0NkEn/c9WF2QYC6O1aMFfoPX
3C80vMD78LeBnoMuYlSYVUlwhg58RkPI2a1C8pSkMmoWlkBTg7UpFoGZpzRQaPh9
mBOoM3WRBBUNuxXT/bYR
=v4Aj
-----END PGP SIGNATURE-----

--S1Xjeh9jebSpqPcPKhTKcQdPR1r5b24sv--
