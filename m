From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] ixgbe: delete one duplicate marcro
 definition of IXGBE_MAX_L2A_QUEUES
Date: Wed, 24 Sep 2014 13:12:45 -0700
Message-ID: <1411589565.2298.10.camel@jtkirshe-mobl>
References: <1411210407-3185-1-git-send-email-ethan.zhao@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5060645890297423889=="
Cc: alexander.h.duyck@intel.com, e1000-devel@lists.sourceforge.net,
	bruce.w.allan@intel.com, jesse.brandeburg@intel.com,
	linux-kernel@vger.kernel.org, john.ronciak@intel.com,
	netdev@vger.kernel.org, linux.nics@intel.co
To: Ethan Zhao <ethan.zhao@oracle.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1411210407-3185-1-git-send-email-ethan.zhao@oracle.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============5060645890297423889==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ltSqhgIXqL5EwNGZDvKE"


--=-ltSqhgIXqL5EwNGZDvKE
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-09-20 at 18:53 +0800, Ethan Zhao wrote:
> There is typo in ixgbe.h, two marcro definition of
> IXGBE_MAX_L2A_QUEUES to 4,
> delete one, clear the compiler warning.
>=20
> Signed-off-by: Ethan Zhao <ethan.zhao@oracle.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)

I have added your patch to my queue, thanks Ethan!

--=-ltSqhgIXqL5EwNGZDvKE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUIyW9AAoJEOVv75VaS+3OMfsP/1QNGN6kIfqhr5pX8pXCw0p8
u15ochu8V7ZtRBWn6v7qTKK/b2LD3ZRX9x9Ja3bslsznHsHRHQbdzlyfE3+IZGdX
6G8+BYEThul3ePUNI7xas+s1SlfM6jWk8aSvNCatexSidDebJDbASC6js+YeULdP
gVHk7Jg4qUBsXJ3d1Of2mxOk1UZjfl0bHNbNyF9waYzAiiNABAuaa7KDk2Mt0Yga
VtnEbQZA/TA86SxGnsFnIMG+GaYq335rwftL3n9fpT32s6/FOHp7EjEvFDZncAFY
9a1zTpho7TQQs53KTensoofVG3NED41Sy+S4DzVbMFU37zuKPI9q024is7lIw+0r
9uzK84CAmYC6SSlABiow7RVoodAcd1Oavya29mjDFh+unlWEb9HsIT8ovm+2+Un7
8ZTDhuECRurYNvTnYQcTYpnvXfR1pg1X794evU9btl4B679O2QCvxxg8eaFsnsWt
gJXoXq9JRGbIMmpPJ4v1drNn1DdaTJpS347R7HFcKuEyuRATK/CUE9wZwdr+xn1C
i9tZoinFm3B8NB2+ZRhOmXSNs22quKkSqbG/n37Txbk74xVO0U/EB52NUHsbDOZf
pnFLnwgI2wq6FvYu/a+kTnheSCNjhAgzmC3KogiYU0IIpZaKMr4/8YxHNk3d+HFD
DkB6fc88HND1WzPmXGRM
=pclj
-----END PGP SIGNATURE-----

--=-ltSqhgIXqL5EwNGZDvKE--



--===============5060645890297423889==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Meet PCI DSS 3.0 Compliance Requirements with EventLog Analyzer
Achieve PCI DSS 3.0 Compliant Status with Out-of-the-box PCI DSS Reports
Are you Audit-Ready for PCI DSS 3.0 Compliance? Download White paper
Comply to PCI DSS 3.0 Requirement 10 and 11.5 with EventLog Analyzer
http://pubads.g.doubleclick.net/gampad/clk?id=154622311&iu=/4140/ostg.clktrk
--===============5060645890297423889==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============5060645890297423889==--
