From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 8/17 v2] can: EG20T PCH: Change Copyright
	and module description
Date: Tue, 07 Dec 2010 09:02:34 +0100
Message-ID: <4CFDEA1A.6020806@pengutronix.de>
References: <4CECC07E.40804@dsn.okisemi.com> <4CECEE1E.9030201@pengutronix.de>
	<EA73672426864370BC8119DE78037132@hacdom.okisemi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6130645607183054773=="
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <EA73672426864370BC8119DE78037132-c0cKtqp5df7I9507bXv2FdBPR1lH4CV8@public.gmane.org>
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
--===============6130645607183054773==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig93A2F7F10533C91968A7794E"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig93A2F7F10533C91968A7794E
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: quoted-printable

On 12/07/2010 01:46 AM, Tomoya MORINAGA wrote:
> On Wednesday, November 24, 2010 7:51 PM, Marc Kleine-Budde wrote:
>> Did your mailer spawn some extra spaces here? The header of your mail
>> tells me:
>> "User-Agent: Mozilla/5.0 (X11; U; Linux i686; ja; rv:1.9.1.15)
>> Gecko/20101027 Thunderbird/3.0.10"
>> I strongly suggest to use git send-email.
>=20
> At last, I can use "git send-email".
> However, I have faced issue.
> In case single destination address is OK, but in case multiple address
> is set,
> I can see the following error.
>=20
> Relay access denied
>=20
> I show my failure command.
> git send-email --smtp-server xxx.com --smtp-server-port yyy --smtp-ssl
> -to aaa.com -to bbb.com -to ccc.com
> -cc ccc.com -cc ddd.com -cc eee.com -bcc fff.com -bcc ggg.com *.patch

According to my man page it's:

--cc=3D<address>
--to=3D<address>

> Do you have any information about the issue ?

Try the above parameter format, if it doesn't work talk to your IT guys.
Have the time stamp and involved addresses (to,cc,smtp-server) of a
working and not working git send-email attempt ready.

cheers, Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig93A2F7F10533C91968A7794E
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkz96hoACgkQjTAFq1RaXHPbQACfbHEcfP5jy44qPVA5iAA7ELiD
834An0X8zTf+cwAqXQmoKO/dyWuPktGu
=n1bF
-----END PGP SIGNATURE-----

--------------enig93A2F7F10533C91968A7794E--

--===============6130645607183054773==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============6130645607183054773==--
