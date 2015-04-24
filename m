From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 00/21] ARCNET: Defibrillation
Date: Fri, 24 Apr 2015 23:14:41 +0200
Message-ID: <553AB241.3080004@pengutronix.de>
References: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de> <1429901273.23327.5.camel@perches.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="BGsftKnTV7tT7FsE1k2QB8pjSGexFAgtX"
Cc: netdev@vger.kernel.org, davem@davemloft.net, kernel@pengutronix.de,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>,
	Michael Grzeschik <m.grzeschik@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429901273.23327.5.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--BGsftKnTV7tT7FsE1k2QB8pjSGexFAgtX
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 04/24/2015 08:47 PM, Joe Perches wrote:
> On Fri, 2015-04-24 at 19:20 +0200, Michael Grzeschik wrote:
>> Hi!
>=20
> Hello.
>=20
>> This patch series tries to reanimate the ARCNET hardware layer to be
>> somehow readable and maintainable again. It includes a lot of cleanup
>> patches. It also adds some fixes which leads the layer to become usabl=
e
>> again. And as a special treatment it adds more features like correct
>> loading and unloading of the com20020 card.
>=20
> Wow.  Good for you, but why?  Does anyone still use these?

Yes, there are parts of the industry where "old" machines are
retrofitted with new hardware...and a lot of these machines still talk
ARCNET :)

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--BGsftKnTV7tT7FsE1k2QB8pjSGexFAgtX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCgAGBQJVOrJBAAoJECte4hHFiupUj+8QAKTUgNt+i6WGvYrGyoua/LL3
7i4WH4ULlvd4XXNrCJqzHHrfj0RUuXdz3cdPsYpo0IcZXXeOFxOExZpBIvz02SIQ
dlJI7ru8ZrqyCkAogQy2HCHM02KvdpAjripuCwo3fLuWBNN0mq4h+eV+MWFEZni7
S5Q2ss1B17aT1T6ORA4RKUsQDe7hDZRnHrOSGxNNZ3TqCEi/HpeaVwjqPXaV8hcQ
EL82A/8p/sJtlLsCMAPdEjHTmFxMOIW+k9uRfAOeghAx6rSkxj0LuxaiOTVlPG+H
bXUASQfrh4B5ChJ/kI80iDOy2yTvW41fziPxVK+luIME/BS+nmPojhiF2oDOorzJ
EjuXwVOxFkSnAAzQQ+5Liut0N/B6AHyVEXWQHWVOVHH1VD0foAC33iya591vCmxB
wA0H9S9aB/OYu62fSbIWOFvLO+RFBE5Bgxx0OilMww0qPzboq5bLiTqPxz21SCVJ
WyUycGbGLRVchHQ4ye600EJ7rE53lc89+1fm+zvv44wYBWR8qdlEMQoZ/+E1rCdY
+H0FVvLYzwShmc6l59EQNxdEAux2xPQD9DGnXvQN3LIIFg8HxeROYZEj/tFrQogB
YbXPBfQLrCyuHLCmTRI+3dkmJ5G221q2vLjjvP/zO1P62iE3lzad/D+47TRn85T8
tRur1Che42kNX9puQeeW
=8O/8
-----END PGP SIGNATURE-----

--BGsftKnTV7tT7FsE1k2QB8pjSGexFAgtX--
