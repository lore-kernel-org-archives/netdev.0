From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 0/5] can: sja1000: cleanups and new OF property
Date: Thu, 30 Jan 2014 17:52:42 +0100
Message-ID: <52EA835A.9040102@pengutronix.de>
References: <1391092168-21246-1-git-send-email-florian.vaussard@epfl.ch> <52EA6E31.2030604@pengutronix.de> <52EA6F6E.1010405@epfl.ch> <52EA718B.3090006@pengutronix.de> <52EA82F5.5000004@epfl.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="kDMpQqhh7oaMVRsAiUaRXefvXP0mnAIpn"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: florian.vaussard@epfl.ch, Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <52EA82F5.5000004@epfl.ch>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--kDMpQqhh7oaMVRsAiUaRXefvXP0mnAIpn
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 01/30/2014 05:51 PM, Florian Vaussard wrote:
>>> Fine. Is an incremental patch on top of this series ok for you ?
>>
>> I'd rather see patches 1 and 2 you have already posted, then probably =
a
>> modernization patch which converts the platform driver to use devm_ an=
d
>> friends. Then a patch adding the existing of bindings [1]. This patch =
is
>> probably quite small if you prepare the driver in the modernization
>> patch properly. The last patch will add the new reg-io-width property.=

>>
>=20
> Ok, I will do it.

If you have questions or work in progress patches feel free to ask.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--kDMpQqhh7oaMVRsAiUaRXefvXP0mnAIpn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlLqg1oACgkQjTAFq1RaXHOjwQCcCGS+SIwwCqqugDCazxHxhG1Q
nFcAnAmV/IzAMEVajNsAsv9h81TBlAaM
=fwaj
-----END PGP SIGNATURE-----

--kDMpQqhh7oaMVRsAiUaRXefvXP0mnAIpn--
