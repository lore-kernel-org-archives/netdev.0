From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH v10 0/5] [flexcan/powerpc] Add support for powerpc flexcan
	(freescale p1010)
Date: Wed, 10 Aug 2011 12:24:16 +0200
Message-ID: <4E425C50.6030508@pengutronix.de>
References: <1312945564-6626-1-git-send-email-holt@sgi.com>
	<4E425716.4010104@pengutronix.de> <20110810101113.GN4926@sgi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3666694717005693140=="
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110810101113.GN4926-sJ/iWh9BUns@public.gmane.org>
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
--===============3666694717005693140==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigBF2531F8679515AE9C064267"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigBF2531F8679515AE9C064267
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 08/10/2011 12:11 PM, Robin Holt wrote:
> On Wed, Aug 10, 2011 at 12:01:58PM +0200, Marc Kleine-Budde wrote:
>> On 08/10/2011 05:05 AM, Robin Holt wrote:
>>> With all the patches applied, my p1010rdb works for communicating bet=
ween
>>> its two can ports and also can communicate with an external PSOC.  I =
have
>>> done no testing beyond compile testing on an arm system as I have no
>>> access to an arm based system.
>>>
>>> For the first three patches in the series, I believe they are all rea=
dy
>>> for forwarding to David S. Miller for the netdev tree.  I think patch=

>>> 4 is ready for submission to the PPC85xx maintainer.  Patch 5 changed=

>>> from the previous post by adding a second compatible string for the
>>> fsl,p1010_flexcan.
>>
>> One remark for the subjects. It seems no one is using "[$subsystem]"
>> anymore, but rather "$subsystem:".
>=20
> I will, one day, get these patches subject lines correct ;)
>=20
> Did you happen to get a chance to test the patches on arm?

It's still compiling...

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigBF2531F8679515AE9C064267
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk5CXFMACgkQjTAFq1RaXHM5CACghJ/nPTGxcIDc/+Pa52zDjVFD
K8AAnA7LJJXdI46isS1qU+RaiSMACBxV
=wXYH
-----END PGP SIGNATURE-----

--------------enigBF2531F8679515AE9C064267--

--===============3666694717005693140==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============3666694717005693140==--
