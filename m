From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 3/9] igb: Convert uses of
 __constant_<foo> to <foo>
Date: Wed, 12 Mar 2014 13:50:33 -0700
Message-ID: <1394657433.2167.5.camel@jtkirshe-mobl>
References: <cover.1394644825.git.joe@perches.com>
	<0eb4523c7e13dc35a6467332e22a24719f7d7041.1394644825.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8403397448866281034=="
Cc: Mitch, e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, John Ronciak <john.ronciak@intel.com>
To: Joe Perches <joe@perches.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <0eb4523c7e13dc35a6467332e22a24719f7d7041.1394644825.git.joe@perches.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============8403397448866281034==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-KsqZb51VKd9n7Hmn550I"


--=-KsqZb51VKd9n7Hmn550I
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-03-12 at 10:22 -0700, Joe Perches wrote:
> The use of __constant_<foo> has been unnecessary for quite awhile now.
>=20
> Make these uses consistent with the rest of the kernel.
>=20
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c | 12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)

Thanks Joe, I will add this to my queue.

--=-KsqZb51VKd9n7Hmn550I
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJTIMiZAAoJEOVv75VaS+3ON54P/3XiDbOsOys6zkoLOefNIyBR
Ix4G5ArXFhe4FNkXGuqrcF0b9XL/SOYSCxIVvv4ELuMTcra12e/W8u4ZDLv9/oJE
+/mnDdKsEh9npric4ZIrPoJHjXQ/G389x7wt6Nmjzkhdn4KRrFBzx9LtwZ3Boc25
gHTwB7rv/4CyjvHZOBu2Cg7zuWXomc4EbwrTLoTSseFh2IoJjtkFfO5U8p2soRBv
mXkHD3uSZQEvj+dIzrDLXcHFOzxTUL9dNx0n4p2ERjRgKNKWkt1trCYTP5av5sab
FC2cqhfpOyUILTGF1CXkaww9IOc5SBzS7+w4uO2L7+WoAIebeX6wdKyllhEv8b8s
c7I/hA/Z9eS8O5qSLgRQH/xrdLo3droEGda0esMsPOrYQfzLEL3tjETedk5sjUyQ
LsYjYA2ONmO4McwTjoMHwQYzdLdJWDqUJuwlzLx6da3adQCV+/xjs9spdUJpf2u5
2jlT4wO3JKl1+L8NclYxnZWy99dVdWN0mH21ih5WMck7Pj2q/OC4Z6YpkgmGtZNP
OwMzv/y3ZgbqS87KVuyIO/ZDzM6fvb1iL2R0Xxw1j1mxhJud3hjLBfab3l/IjKUf
ComnXrAiJEVdd5E07tkQ8JiipMZ9ZyinpbKfE4MsUyRRBaOVxTq9PrAPm/N86lMO
JuJ/DkScmpClLrH84wsF
=REfh
-----END PGP SIGNATURE-----

--=-KsqZb51VKd9n7Hmn550I--



--===============8403397448866281034==
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
--===============8403397448866281034==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============8403397448866281034==--
