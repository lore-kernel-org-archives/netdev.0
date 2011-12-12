From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next] can: plx_pci: add support for IXXAT PCI cards
Date: Mon, 12 Dec 2011 14:40:12 +0100
Message-ID: <4EE6043C.8070501@pengutronix.de>
References: <166589D0B9DD2547A1319599B9BADA1FC62431@vsv-exchange.ixxat.intranet.priv>
	<4EE5DF4A.80301@grandegger.com>
	<166589D0B9DD2547A1319599B9BADA1FC62485@vsv-exchange.ixxat.intranet.priv>
	<4EE6001F.3010304@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3980454086633035087=="
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4EE6001F.3010304-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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
--===============3980454086633035087==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigFA456BD1C4FD062E6C4F5A11"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigFA456BD1C4FD062E6C4F5A11
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 12/12/2011 02:22 PM, Wolfgang Grandegger wrote:
> On 12/12/2011 01:45 PM, kime-Z4QKGCRq86k@public.gmane.org wrote:
>> This patch adds support for IXXAT passive CAN controllers
>>
>> Signed-off-by: James Kime <kime-Z4QKGCRq86k@public.gmane.org>
>=20
> Acked-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
>=20
> Looks good now. Next time, please do not send a revised patch as "Re: "=

> but as "[PATCH net-next v2]", also to make "git am" happy.

Thanks, the patch is in the linux-can-next repo now.
I've fixed up the author.

https://gitorious.org/linux-can/linux-can-next

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigFA456BD1C4FD062E6C4F5A11
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk7mBD8ACgkQjTAFq1RaXHPXcwCePGY9w4TrTQMViOK6k5c0qmtH
VFEAn2SloVml5pw8J4xMAHZpHRfHFxdP
=rpz8
-----END PGP SIGNATURE-----

--------------enigFA456BD1C4FD062E6C4F5A11--

--===============3980454086633035087==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============3980454086633035087==--
