From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 01/19 v5] can: EG20T PCH: Separate Interface
	Register(IF1/IF2)
Date: Mon, 29 Nov 2010 11:08:06 +0100
Message-ID: <4CF37B86.6030708@pengutronix.de>
References: <4CEF150A.7080409@dsn.okisemi.com>	<4CEF84BE.7000101@pengutronix.de>
	<4CEF864B.6080207@pengutronix.de>
	<002201cb8f69$11d30050$66f8800a@maildom.okisemi.com>
	<4CF370D3.7020606@pengutronix.de>
	<001501cb8faa$3cc7f220$66f8800a@maildom.okisemi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3041098410154646153=="
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <001501cb8faa$3cc7f220$66f8800a-a06+6cuVnkTSQfdrb5gaxUEOCMrvLtNR@public.gmane.org>
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
--===============3041098410154646153==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig902E9101C6EBAF5795718CB5"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig902E9101C6EBAF5795718CB5
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 11/29/2010 10:46 AM, Tomoya MORINAGA wrote:
> On Monday, November 29, 2010 6:22 PM, Marc Kleine-Budde wrote :
>=20
>> Maybe your patch description in git commit is unusual. It should be a
>> one line patch subject, followed by a blank line, then a multi line
>> patch description.=20
> Adding blank line below subject line, I could confirm=20
> whitespace is not inserted.

\o/

regards,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig902E9101C6EBAF5795718CB5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkzze4kACgkQjTAFq1RaXHNvPgCgiUFJob2VcE/1sfE2qDFDmT3v
rIQAoI9lPqVQLyeaHquxZTrUcGiN5bts
=MBM7
-----END PGP SIGNATURE-----

--------------enig902E9101C6EBAF5795718CB5--

--===============3041098410154646153==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============3041098410154646153==--
