From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 0/4] i40e: Neatening and object size
	reductions
Date: Fri, 30 Aug 2013 19:12:10 -0700
Message-ID: <1377915130.2030.39.camel@jtkirshe-mobl>
References: <cover.1377903831.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0253751280563727801=="
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1377903831.git.joe@perches.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============0253751280563727801==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-R4gStmPOyFlrWktE4Wco"


--=-R4gStmPOyFlrWktE4Wco
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2013-08-30 at 16:06 -0700, Joe Perches wrote:
> Just some potential cleanings...
>=20
> Joe Perches (4):
>   i40e: Whitespace cleaning
>   i40e: Add and use pf_<level>
>   i40e: pf_<level> remove "%s: " ... __func__
>   i40e: Convert pf_<level> macros to functions

Thanks Joe, I will add these to my queue.

--=-R4gStmPOyFlrWktE4Wco
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAABCgAGBQJSIVD6AAoJEOVv75VaS+3OKxQP/RAcDOeW/FBvLU+6JNSTri59
MpESVelGQUOsUzhzWxYoPJkpfWUlZEH+o+NCrs9zq9E5eon9qUPN9XPROKbbyvZU
wj4SU0tOfRih4EwE3VkdJiUCksWc7VVby0gXaz1FAWzRtIfPDwh3u2mDRPvZxL4J
Ats5g7QJAaUJ1szRezdcXC4SHfWXNZciEfCL/soxmLajhN7fmPw5S7QqdaOKLuEU
+/k1PNGasaKZSUvN96UDj5b92BaLJsC99Fs9HIsnjAt+t9WpZPN1QdWz/cdnwPRr
0s5L8552nTtytXJKK1hZU0oIWJICSfkTNfClVbX1HRoM9qy0ABSlQDpe7Dh+PnWL
ToIlWWMJtWinWIwANXss+C+T2AfzSVXoGktTTdVFPEJBsSPcai7/xTSG4VOVFBHo
6ypyZ2zo8KghxjEwV5bGiCi26fcenzcn9tbwygOFRwg7X2yY64K8sdPEWHMfFzdH
JyWcIYdpRBJ8FXfJxyi8m3eZhZceq9tMwWMoNNpJzTlq+pRscRIJOTl6CY/snUdN
FT3KW0xjNG+kVLcPEM/bejauqzfrm74V7RVn1HjJkDnyEU4jD8j7DxX9NiYtfzOT
QNu7QuQeqUovQi+qmiwnhgbIiajQBhXxikgkw+i63NtKx2GvsPuZ5F06f87gn3lu
LQ7+0zlWzkGuggiBYJBc
=S0Fm
-----END PGP SIGNATURE-----

--=-R4gStmPOyFlrWktE4Wco--



--===============0253751280563727801==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Learn the latest--Visual Studio 2012, SharePoint 2013, SQL 2012, more!
Discover the easy way to master current and previous Microsoft technologies
and advance your career. Get an incredible 1,500+ hours of step-by-step
tutorial videos with LearnDevNow. Subscribe today and save!
http://pubads.g.doubleclick.net/gampad/clk?id=58040911&iu=/4140/ostg.clktrk
--===============0253751280563727801==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============0253751280563727801==--
