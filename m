From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: tscan1: Utilize the module_isa_driver macro
Date: Fri, 17 Jun 2016 12:29:25 +0200
Message-ID: <d45a5da1-c791-0e93-1830-4ee05d0f6234@pengutronix.de>
References: <20160601125951.GA31041@sophia>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="HFa5CnFqlO5JivnBdgo3AlwqgXSQMTAaU"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: William Breathitt Gray <vilhelm.gray@gmail.com>, wg@grandegger.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20160601125951.GA31041@sophia>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--HFa5CnFqlO5JivnBdgo3AlwqgXSQMTAaU
Content-Type: multipart/mixed; boundary="E4MkcnmcqbkU3OQUJ3X3Iip96SucL4D5k"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: William Breathitt Gray <vilhelm.gray@gmail.com>, wg@grandegger.com
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org
Message-ID: <d45a5da1-c791-0e93-1830-4ee05d0f6234@pengutronix.de>
Subject: Re: [PATCH] can: tscan1: Utilize the module_isa_driver macro
References: <20160601125951.GA31041@sophia>
In-Reply-To: <20160601125951.GA31041@sophia>

--E4MkcnmcqbkU3OQUJ3X3Iip96SucL4D5k
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 06/01/2016 02:59 PM, William Breathitt Gray wrote:
> This driver does not do anything special in module init/exit. This patc=
h
> eliminates the module init/exit boilerplate code by utilizing the
> module_isa_driver macro.
>=20
> Signed-off-by: William Breathitt Gray <vilhelm.gray@gmail.com>

Applied to can-next.

Tnx,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--E4MkcnmcqbkU3OQUJ3X3Iip96SucL4D5k--

--HFa5CnFqlO5JivnBdgo3AlwqgXSQMTAaU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJXY9EFAAoJED07qiWsqSVqQJcIAIKaWTYJ8n7d+RnIdOWh61A9
m/MoasAAuArPsfsSdAj+JvCF87GGpckmlEs39evhoMOvL5D4S/dcVTRHrn1XrOPa
oXOlFlMvO1uNR+HBirVhtwR5tYjcpDjnyWvce2F6DT34VHXVGS0oi/AlDd8v3J/Q
0qXO4bkVamTIuqfhg34IWPNDqa8zgjXGmlNsiJ5B/Txca3X+nTSAoWBxBwzGkJhf
nu+gxjGIkEJj4h1RTHwGsYy8LzyJlDS4KejVth4s+mJE3SOoZLas04LcH7b68y1r
7jWKS4D7M/cKTh42dYrneSPCAACmY2Uh6/wDo7L+zdiOOGF606tvsuylaGKrqt4=
=1fVy
-----END PGP SIGNATURE-----

--HFa5CnFqlO5JivnBdgo3AlwqgXSQMTAaU--
