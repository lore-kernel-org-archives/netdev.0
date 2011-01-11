From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v3 1/1] can: c_can: Added support for Bosch
	C_CAN controller
Date: Tue, 11 Jan 2011 23:01:47 +0100
Message-ID: <4D2CD34B.8000609@pengutronix.de>
References: <1294135195-9448-1-git-send-email-bhupesh.sharma@st.com>	<4D2829C5.5020206@grandegger.com>	<D5ECB3C7A6F99444980976A8C6D896384DEAFA2D9D@EAPEX1MAIL1.st.com>
	<4D2C14FE.7080903@grandegger.com> <4D2CA0AA.6080505@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1435740107854944712=="
Cc: Wolfram Sang <wsa-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org" <Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4D2CA0AA.6080505-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============1435740107854944712==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig63E6082BFD088CB6EB9DD5F4"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig63E6082BFD088CB6EB9DD5F4
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 01/11/2011 07:25 PM, Wolfgang Grandegger wrote:

[...]

> I was told that Bosch's page for the C_CAN is here:
>=20
>  http://www.semiconductors.bosch.de/en/ipmodules/can/canipmodules/c_can=
/c_can.asp
>=20
> There it's also written for what bus interfaces the C_CAN is available =
for, e.g.:
>=20
>   "The ASIC version is delivered with the AMBA APB bus interface from A=
RM."

On ARM we also have the AMBA bus abstraction in Linux, but I've never
worked with it. IIRC Wolfram (Cc'ed) has recently touched it.

> which is obviously used in the "Platform Controller Hub" eg20t.

But in the pch, they've attached the AMBA to the PCI bus.

cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig63E6082BFD088CB6EB9DD5F4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk0s03gACgkQjTAFq1RaXHPqbwCfRoW3DaaPXaDu5YHy1BodA+y9
2FYAn0jj5cxuciUA19jZhKvxc8e1GNDr
=Gh1U
-----END PGP SIGNATURE-----

--------------enig63E6082BFD088CB6EB9DD5F4--

--===============1435740107854944712==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============1435740107854944712==--
