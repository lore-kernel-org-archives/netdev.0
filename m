From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 4/9] igbvf: Convert uses of
 __constant_<foo> to <foo>
Date: Wed, 12 Mar 2014 13:50:44 -0700
Message-ID: <1394657444.2167.6.camel@jtkirshe-mobl>
References: <cover.1394644825.git.joe@perches.com>
	<52ad53c6822c19de67480e8b3e36201a30cab308.1394644825.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============9077819239778397752=="
Cc: Mitch, e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, John Ronciak <john.ronciak@intel.com>
To: Joe Perches <joe@perches.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <52ad53c6822c19de67480e8b3e36201a30cab308.1394644825.git.joe@perches.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============9077819239778397752==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-IngQUu5MJa5qD6Vs4F/Z"


--=-IngQUu5MJa5qD6Vs4F/Z
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-03-12 at 10:22 -0700, Joe Perches wrote:
> The use of __constant_<foo> has been unnecessary for quite awhile now.
>=20
> Make these uses consistent with the rest of the kernel.
>=20
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/ethernet/intel/igbvf/netdev.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

Thanks Joe, I will add this to my queue.

--=-IngQUu5MJa5qD6Vs4F/Z
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJTIMikAAoJEOVv75VaS+3O98wP/052ZM1D8yKOKs+b2iYn9e86
mAXVZup5mOOWqJZ1gwC0qoMgdomwVnmCQsaz+9lUyKQszvd6qTI7nExdPcHRr8BD
aiVkbewCGhYZQp0x1gyiimmdMdNgu0NNCBqTMVHdj3vXg3BJN8Fri6PDP7/jFbNW
b6xGdqpv7bA4w9coV9wn3JQOG128Wd+hI9xrm2+WtcqV3f9PfrGPllw5R3telm7m
KqbOUZIMrdo9vApFedvjwHLNExIsSpnDadtAfMb+dW4NiJun4+21wRs7jSUfbNsV
b4thMD27oWigPbjI2jo+VCJdCMpG5b/79d7qoipoJhVHTe2YdEb4ic70Wz/x0Ph3
xHt8n7tJTk7hKBccXdZwv8KLp6CsCswgO/C4tkQenK/XAz2VriACGwiVukPnhRfw
U1D/K8b23NcsGEmfU4IJG0pXj3FCvgRZTQlHySsYArOG8w6JCllQx9jIYtbuD47M
lQIH6iR3Qb2mCw6adT/ceWejoPvB4cD3GDiLvmwFyHOdfjCxctjcCCzRw/2/you2
jMimtO/URP+CL7VK9MJYuENpEe7lyyF8Q9LcV+D0HJ6m1vr+ft0UvvJbz1KXSlM+
GG+1Quhu5Bt/BVE/5k7Zqqp0YZeIRENOtjgQUrhkBD/5Rpp1IbNUSkL0UAuueWgT
3m13UOSNlnK2i3DvrEfX
=dSjT
-----END PGP SIGNATURE-----

--=-IngQUu5MJa5qD6Vs4F/Z--



--===============9077819239778397752==
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
--===============9077819239778397752==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============9077819239778397752==--
