From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH 0/2] can: mcp251x: fix error handling and error frames bug
Date: Wed, 20 Oct 2010 12:16:10 +0200
Message-ID: <4CBEC16A.2010205@pengutronix.de>
References: <1287568946-32727-1-git-send-email-mkl@pengutronix.de>
	<4CBEC06D.6000102@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2179015980344664802=="
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4CBEC06D.6000102-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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
--===============2179015980344664802==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigD526C733CD34FF598401FF0A"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigD526C733CD34FF598401FF0A
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 10/20/2010 12:11 PM, Wolfgang Grandegger wrote:
>> this series of patches fixes two bugs, one introduced by me in the oth=
er=20
>> mcp251x series.
>>
>> Please test, especially the error handling, i.e. wrong bitrate, shortc=
ut in
>> CAN bus. I'm also interested in tests with non i.MX SPI can cores.
>=20
> You can add my Acked-by but more Tested-by's are definitely more useful=
=2E

Thanks and ACK :)

> Unfortunately, I do not have that hardware at hand.

I'm sure Jargalan is going to test it.

cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigD526C733CD34FF598401FF0A
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAky+wWoACgkQjTAFq1RaXHMvAACeOZ9deZf9FVorXOOaDpDedkmO
IUIAnjVGk/+qRzY76va7iBlb8HIYCwQM
=d9KV
-----END PGP SIGNATURE-----

--------------enigD526C733CD34FF598401FF0A--

--===============2179015980344664802==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============2179015980344664802==--
