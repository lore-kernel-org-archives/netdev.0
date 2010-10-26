From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v2] can: Topcliff: PCH_CAN driver: Fix build
	warnings
Date: Tue, 26 Oct 2010 20:52:16 +0200
Message-ID: <4CC72360.1070608@pengutronix.de>
References: <4CC61B1B.3090602@dsn.okisemi.com>	<20101026.105206.15244527.davem@davemloft.net>	<20101026.105545.200376685.davem@davemloft.net>
	<4CC71DA4.3020600@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5768694853536098649=="
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org,
	kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, chripell-VaTbYqLCNhc@public.gmane.org,
	morinaga526-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4CC71DA4.3020600-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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
--===============5768694853536098649==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig25F0404BD3A0EB13A51464B9"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig25F0404BD3A0EB13A51464B9
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 10/26/2010 08:27 PM, Wolfgang Grandegger wrote:

> Oh, this patch has various other issues, as Marc and I have already
> pointed out, which should be fixed before the driver hits the user.
> Unfortunately, the CC to netdev of our reviews got lost somehow, sorry

After noticing my faul I resend my review to the netdev + socketcan
mailinglists and the individual persons mentioned in the original patch.

> for the inconvenience, but the original author should have received it.=

> Tomoya, could you (or somebody else) please also fix the remaining
> issues quickly?

For reference, here it is:
http://www.spinics.net/lists/netdev/msg144852.html

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig25F0404BD3A0EB13A51464B9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkzHI2QACgkQjTAFq1RaXHM/DwCcCvIFej7VdTLSPUr9ezOmk7Ua
f7wAn3qmz+Km9M8/Z6XgsfyrHnUepWZY
=ZbQZ
-----END PGP SIGNATURE-----

--------------enig25F0404BD3A0EB13A51464B9--

--===============5768694853536098649==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============5768694853536098649==--
