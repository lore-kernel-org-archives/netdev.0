From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2 0/2] can: Add r8a7796 support to CAN/CAN FD
Date: Fri, 25 Nov 2016 08:19:07 +0100
Message-ID: <1207930c-e9ad-27eb-f5a6-d889771fd840@pengutronix.de>
References: <1479903243-1860-1-git-send-email-chris.paterson2@renesas.com>
 <1480003917-3953-1-git-send-email-chris.paterson2@renesas.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="QxBqHiksG8pIPKJlKpD3AVNwOgmPSv9bh"
Cc: Wolfgang Grandegger <wg@grandegger.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        Simon Horman <horms@verge.net.au>,
        Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>,
        linux-can@vger.kernel.org, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: Chris Paterson <chris.paterson2@renesas.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1480003917-3953-1-git-send-email-chris.paterson2@renesas.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--QxBqHiksG8pIPKJlKpD3AVNwOgmPSv9bh
Content-Type: multipart/mixed; boundary="ITqXwFTsfhkdXiHXNwrbkeqfkxBJKer66";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Chris Paterson <chris.paterson2@renesas.com>
Cc: Wolfgang Grandegger <wg@grandegger.com>, Rob Herring
 <robh+dt@kernel.org>, Mark Rutland <mark.rutland@arm.com>,
 Geert Uytterhoeven <geert+renesas@glider.be>,
 Simon Horman <horms@verge.net.au>,
 Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>,
 linux-can@vger.kernel.org, netdev@vger.kernel.org,
 devicetree@vger.kernel.org, linux-renesas-soc@vger.kernel.org
Message-ID: <1207930c-e9ad-27eb-f5a6-d889771fd840@pengutronix.de>
Subject: Re: [PATCH v2 0/2] can: Add r8a7796 support to CAN/CAN FD
References: <1479903243-1860-1-git-send-email-chris.paterson2@renesas.com>
 <1480003917-3953-1-git-send-email-chris.paterson2@renesas.com>
In-Reply-To: <1480003917-3953-1-git-send-email-chris.paterson2@renesas.com>

--ITqXwFTsfhkdXiHXNwrbkeqfkxBJKer66
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 11/24/2016 05:11 PM, Chris Paterson wrote:
> This series adds support for r8a7796 to rcar_can and rcar_canfd.
>=20
> Original series: [PATCH 0/3] arm64: dts: r8a7796: Add CAN/CAN FD suppor=
t.
>=20
> Changes since v1:
> - Split bindings documentation changes from device tree changes.
> - Rebased on renesas-devel-20161123v2-v4.9-rc6.
>=20
>=20
> Chris Paterson (2):
>   can: rcar_can: Add r8a7796 support
>   can: rcar_canfd: Add r8a7796 support

Both added to can-next.

Thanks,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--ITqXwFTsfhkdXiHXNwrbkeqfkxBJKer66--

--QxBqHiksG8pIPKJlKpD3AVNwOgmPSv9bh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEES2FAuYbJvAGobdVQPTuqJaypJWoFAlg35e0ACgkQPTuqJayp
JWpoqggAh7NurPpr5AyJuBGperq4j/0gMKUU3wXN2oaSLaRQOP2+vWwp7pjo48SS
upuiicgFGNe9d7favlzbWPGjlmXgWGWyX9X6exQ2mTD0jd8fvP/axdzfCKdN6/e7
cG40wB+P7BNIklMtkJSA7FhtpxSPI+Zuny4AVpT8qyJhWrEkaMh/Rp7tjy4c0aFu
kKEW9Gi9uKn2G7fotiRI6zMTImtAxuHtxySJ/nQ6ZMf/g/7geGRW1iycTnBouwFe
/+/hf/ESJCUVwo+NydsJ/m3smz6Oh372H+NIi981hfXD06MihqXPVlqcMp5snccH
NzL/KSUd/V6c3oYdOxmtHFJCo018DA==
=KYai
-----END PGP SIGNATURE-----

--QxBqHiksG8pIPKJlKpD3AVNwOgmPSv9bh--
