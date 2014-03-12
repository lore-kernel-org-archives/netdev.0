From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 2/9] e100: Convert uses of
 __constant_<foo> to <foo>
Date: Wed, 12 Mar 2014 13:50:23 -0700
Message-ID: <1394657423.2167.4.camel@jtkirshe-mobl>
References: <cover.1394644825.git.joe@perches.com>
	<b7d59e4e50e0e90546ca66d2865d52552be1e553.1394644825.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2170273426019487032=="
Cc: Mitch, e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, John Ronciak <john.ronciak@intel.com>
To: Joe Perches <joe@perches.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <b7d59e4e50e0e90546ca66d2865d52552be1e553.1394644825.git.joe@perches.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============2170273426019487032==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-5K1HhXztbhLFDj+7PQuq"


--=-5K1HhXztbhLFDj+7PQuq
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-03-12 at 10:22 -0700, Joe Perches wrote:
> The use of __constant_<foo> has been unnecessary for quite awhile now.
>=20
> Make these uses consistent with the rest of the kernel.
>=20
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/ethernet/intel/e100.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

Thanks Joe, I will add this to my queue.

--=-5K1HhXztbhLFDj+7PQuq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJTIMiPAAoJEOVv75VaS+3OhVAP/1rhk+DTQGNIff/EkGyaiAzK
Fx3q43QXoCxWYyTcZYrm+rDIvd0e7ud/Rd6BaRHTzK6mKANWK+WlJGbW1bqNa4By
qJJ12WGjkLcaM4yY4UU5mi5iox8FI7teRdOLRzLZyQ5Bu5uCbxpVNk78/ScemDFT
nB47qAveD5dSiZn1LCnY0XIF3Twy6s+i4cc7UGmXc7snwo6ai62Rk9ygFHXUPXU8
27Djsp42layAOL2vYhIEKqgt1rnu+4+raktCZebpu7TDGboA2CwiIh7RGF86CcO6
wRUTz/8I3cb6/01TWGC21LHhaDYIcRxxeHtXXE+ywcR0PmyXQi33PEBYeOlnmNBk
Pwc/1mgiUNS6PsIVa2GMa49dkaGHhh9+X3U7xIkBCOrpH2i11fO44AgzlzGwFs4t
FvUWGThp+lHVHqRo9qwM9Jxi9iMsVire1g3Ug8C9m9D4kFcGuoJTk3JOjFe9UOP0
2JiDjX+ds9iUw4ADa+xCqe+JIfdqH7LXHmijkChpIEI2OHgStraVhiE1aWQWbr4o
eQHul4+zfKpjZf5TSNT9jCJ51MxK/YYhGmOfoRxtnMuVqg1aKASf0uldp7dsNgOi
QI55royh9tWWMgRsE5+IqnsA5+gqJhQ72hgoDG5zqD0OG/hWpWZa7l5Qo8r4fMND
E1/xYClbsV+QkLjBaeOg
=X7j2
-----END PGP SIGNATURE-----

--=-5K1HhXztbhLFDj+7PQuq--



--===============2170273426019487032==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
--===============2170273426019487032==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============2170273426019487032==--
