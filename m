From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v3 1/2] rcar_can: document device tree bindings
Date: Tue, 05 Aug 2014 08:15:43 +0200
Message-ID: <53E0768F.8030406@pengutronix.de>
References: <201408010124.26505.sergei.shtylyov@cogentembedded.com> <53DAB5CF.8000407@pengutronix.de> <53DFC0CE.4050602@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="xn8EFqBR5OMu8Sj3dp8lr4UR5M4vTQgkG"
Cc: netdev@vger.kernel.org, wg@grandegger.com,
	linux-can@vger.kernel.org, linux-sh@vger.kernel.org,
	vksavl@gmail.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	devicetree@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <53DFC0CE.4050602@cogentembedded.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--xn8EFqBR5OMu8Sj3dp8lr4UR5M4vTQgkG
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 08/04/2014 07:20 PM, Sergei Shtylyov wrote:
> Hello.
>=20
> On 08/01/2014 01:31 AM, Marc Kleine-Budde wrote:
>=20
>>> Document the R-Car CAN device tree bindings.
>=20
>>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>=20
>> The series looks good from the CAN perpective. I'll apply the patches
>> after we've got an Acked-by from the DT folks.
>=20
>    How about the prior CAN clock support patch?

That looks good, too.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--xn8EFqBR5OMu8Sj3dp8lr4UR5M4vTQgkG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlPgdo8ACgkQjTAFq1RaXHNdOACfXuSAf+fJj41EgZ/2jJLn4/O3
ANoAn2/h1ZSLnl326pdZm1QK5jBvaduT
=ZqsA
-----END PGP SIGNATURE-----

--xn8EFqBR5OMu8Sj3dp8lr4UR5M4vTQgkG--
