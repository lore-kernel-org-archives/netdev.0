From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v3 1/1] can: c_can: Added support for Bosch
	C_CAN controller
Date: Thu, 06 Jan 2011 20:44:36 +0100
Message-ID: <4D261BA4.2020003@pengutronix.de>
References: <1294135195-9448-1-git-send-email-bhupesh.sharma@st.com>	<20110106.113356.102556872.davem@davemloft.net>
	<4D261AAA.5030005@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3107986359821671244=="
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4D261AAA.5030005-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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
--===============3107986359821671244==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigDF0BBA439C9D3722317CCB08"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigDF0BBA439C9D3722317CCB08
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hello Wolfgang,

On 01/06/2011 08:40 PM, Wolfgang Grandegger wrote:
> On 01/06/2011 08:33 PM, David Miller wrote:
>> From: Bhupesh Sharma <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
>> Date: Tue, 4 Jan 2011 15:29:55 +0530
>>
>>> Bosch C_CAN controller is a full-CAN implementation which is complian=
t
>>> to CAN protocol version 2.0 part A and B. Bosch C_CAN user manual can=
 be
>>> obtained from:
>>> http://www.semiconductors.bosch.de/pdf/Users_Manual_C_CAN.pdf
>>
>> Can someone please review this driver submission?
>=20
> Yes, of course. I'm still on holiday, hope to find some time tomorrow.

If this driver will be merged, we'll have two drivers for the same can
core in the tree. The other one is the pch_can. What do you think should
be the mid term perspective for ccan based hardware?

regards, Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigDF0BBA439C9D3722317CCB08
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk0mG6oACgkQjTAFq1RaXHPs+QCfUAxbHsKbwssUJJiYTWTNUHzI
vwYAn1wqcmTIoZt92hD4+mU7IWuuDoBF
=yP1i
-----END PGP SIGNATURE-----

--------------enigDF0BBA439C9D3722317CCB08--

--===============3107986359821671244==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============3107986359821671244==--
