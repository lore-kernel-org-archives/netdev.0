From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v1] can: Topcliff: Update PCH_CAN driver
	to 2.6.35
Date: Mon, 25 Oct 2010 00:15:21 +0200
Message-ID: <4CC4AFF9.90009@pengutronix.de>
References: <4CB8506C.3060600@dsn.okisemi.com>	<20101024.144312.104048720.davem@davemloft.net>	<4CC4ADA5.8@pengutronix.de>
	<20101024.150905.39179588.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4725454382586474530=="
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org,
	sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	morinaga526-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	chripell-VaTbYqLCNhc@public.gmane.org, wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20101024.150905.39179588.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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
--===============4725454382586474530==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigF19D9FFDB3F1EE694E8482CE"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigF19D9FFDB3F1EE694E8482CE
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 10/25/2010 12:09 AM, David Miller wrote:
> From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> Date: Mon, 25 Oct 2010 00:05:25 +0200
>=20
>> On 10/24/2010 11:43 PM, David Miller wrote:
>>> From: Masayuki Ohtak <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
>>> Date: Fri, 15 Oct 2010 22:00:28 +0900
>>>
>>>> CAN driver of Topcliff PCH
>>>>
>>>> Topcliff PCH is the platform controller hub that is going to be used=
 in
>>>> Intel's upcoming general embedded platform. All IO peripherals in
>>>> Topcliff PCH are actually devices sitting on AMBA bus.=20
>>>> Topcliff PCH has CAN I/F. This driver enables CAN function.
>>>>
>>>> Signed-off-by: Masayuki Ohtake <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
>>>
>>> Applied, thanks.
>>
>> IMHO this driver needs some improvements. There are some open points
>> from Wolfgangs and my review. On the other side, it's a new driver and=

>> there's some time left before it hits mainline.
>=20
> When people have more than a week to review and provide feedback,
> and don't, I have zero sympathy especially this early in the
> release cycle.

Let me see....Crap, it's my fault, I just replied to the socketcan
mailinglist ;( [1]

> So if adding it to the tree is what I have to do to get you guys to
> post your comments and suggest fixes, then that's what I am going to
> (continue) to do. :-)

=2E..or to learn how to reply properly :)

regards, Marc

[1]
https://lists.berlios.de/pipermail/socketcan-core/2010-October/004757.htm=
l
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigF19D9FFDB3F1EE694E8482CE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkzEr/0ACgkQjTAFq1RaXHNN1QCgic3MJusAQnGIGNIFqgpl7oR3
5QMAn0VvKXyVl/IUFVQDZRcE9l5M4SlM
=qrqH
-----END PGP SIGNATURE-----

--------------enigF19D9FFDB3F1EE694E8482CE--

--===============4725454382586474530==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============4725454382586474530==--
