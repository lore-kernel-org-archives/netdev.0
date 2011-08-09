From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [RFC 4/4] [powerpc] Add flexcan device support for p1010rdb.
Date: Tue, 09 Aug 2011 15:09:26 +0200
Message-ID: <4E413186.1010708@pengutronix.de>
References: <1312869313-22434-1-git-send-email-holt@sgi.com>
	<1312869313-22434-5-git-send-email-holt@sgi.com>
	<4E41291B.3020001@pengutronix.de> <20110809124042.GR4926@sgi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0832793615811320918=="
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110809124042.GR4926-sJ/iWh9BUns@public.gmane.org>
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
--===============0832793615811320918==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig617B6AA3EDD354988573323D"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig617B6AA3EDD354988573323D
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 08/09/2011 02:40 PM, Robin Holt wrote:
> On Tue, Aug 09, 2011 at 02:33:31PM +0200, Marc Kleine-Budde wrote:
>> On 08/09/2011 07:55 AM, Robin Holt wrote:
>>> I added a clock source for the p1010rdb so the flexcan driver
>>> could find its clock frequency.
>>>
>>> Signed-off-by: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
>>> To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
>>> To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
>>> To: U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
>>> Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
>>> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
>>> Cc: PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
>>
>> After fixing Wolfgangs remarks add by Acked-by, for what it's worth in=

>> the ppc-world :)
>=20
> Does that go for the other two patches in the series you have not
> commented on in many revs as well?

They look pretty good so far! I'll compile the next round on arm and
hopefully find time to test on HW.

cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig617B6AA3EDD354988573323D
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk5BMYkACgkQjTAFq1RaXHM5wACfVsXVhw3mrK+pa1cXW6DN2J7Q
uIcAn2r0GGrsiTy0uW8CKTDwAW7cLb+H
=e0En
-----END PGP SIGNATURE-----

--------------enig617B6AA3EDD354988573323D--

--===============0832793615811320918==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============0832793615811320918==--
