From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: pull-request: can 2015-08-24
Date: Tue, 25 Aug 2015 08:49:15 +0200
Message-ID: <55DC0FEB.2040403@pengutronix.de>
References: <1440408003-13085-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="KwJPf4aCWDnVN63mW6vWkxpcMbAI0GAB5"
Cc: davem@davemloft.net, kernel@pengutronix.de,
	linux-can@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1440408003-13085-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--KwJPf4aCWDnVN63mW6vWkxpcMbAI0GAB5
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 08/24/2015 11:20 AM, Marc Kleine-Budde wrote:
> Hello David,
>=20
> this is a pull request of one patch by me for the peak_usb driver. It f=
ixes the
> driver, so that non FD adapters don't provide CAN FD bittimings.

As there are some typos in the commit message I'll send an updated pull
request. David, please don't pull this one.

thanks,
Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--KwJPf4aCWDnVN63mW6vWkxpcMbAI0GAB5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJV3A/rAAoJEP5prqPJtc/HFtQH/iWIzn7i01SUeSCFI0o4qR7X
wcDY0kJe/Fi8wgob6A88fPIkxqON57BA7sqyQ6HNnQxoATNYaq3sRb+zPA3qC6M5
Gm7FNKtNBfn15dpuuPBFjm0OHRqz7svHPQxsji7j1yEY9ArXQjBI0Qm9K2HFijNp
okj9IKk3ofmunq/dkOpWZGThx60nJUpV2BLkZLGEEToMSFdg9GzD0VdHgD8/K/k7
mJeSdjAg+B6fW273daM9yYL5x7CtYnpidUkek5pK/B/qF2+HMO4RQIxNuF57rTMR
yP7I6cOQdCeCYKEqoWG14WYiW67J1N1tiYsBq/EvgEBo7u+xCaWM4zn2qbppo9E=
=nQt+
-----END PGP SIGNATURE-----

--KwJPf4aCWDnVN63mW6vWkxpcMbAI0GAB5--
