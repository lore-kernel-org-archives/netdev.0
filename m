From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 4/7] net: rfkill: gpio: fix reversed clock
 enable state
Date: Tue, 15 Apr 2014 16:27:00 +0200
Message-ID: <20140415142700.GF3207@lukather>
References: <1397544101-18135-1-git-send-email-wens@csie.org>
 <1397544101-18135-5-git-send-email-wens@csie.org>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="2FkSFaIQeDFoAt0B"
Cc: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Heikki Krogerus <heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Mika Westerberg <mika.westerberg-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>, linux-gpio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Return-path: <linux-sunxi+bncBD2ZNBF5VYJRB3MEWWNAKGQETT4OQZQ-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1397544101-18135-5-git-send-email-wens-jdAy2FN1RRM@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org


--2FkSFaIQeDFoAt0B
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Apr 15, 2014 at 02:41:38PM +0800, Chen-Yu Tsai wrote:
> rfkill-gpio has clk_enabled =3D blocked, which is true when rfkill
> blocks the device. This results in calling clock enable/disable at
> the wrong time. Reversing the value fixes this.
>=20
> Signed-off-by: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>

Acked-by: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>

Thanks!
Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com

--2FkSFaIQeDFoAt0B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIbBAEBAgAGBQJTTUG0AAoJEBx+YmzsjxAg6CEP93OnZUrmCgxusnW1kCg8OUN3
OJXIJEg+vKvI3AkFuKDN5l5CVmWngT1TnaRj4TvPOza1YaL+TorEIKIxZUEhj+QV
AP1ViZW+xUJhC6Ky6dYKp3UI7s3xh28Vev6tuPI+G26B+FfAwTp0nVmujXyBT0cD
CL3CgLCCS5SBBaZonIIL9roHdhBoZJUseFyXNSCmYDBnp0keMxpz3CBs5WnFaE0o
3vE+KUWoYy90WzbxiZjxaqxAiHOHL2gkev0XQFusvr31ZeZ15KkdZILfo9YXVhTT
/u0XkQXh1D16QKZWnoW072pNwZSm/XezbSLUp+XJRVETa3X6PI7GNyhba0U7i8J6
Q0gqZAUC2chIRBzcR0P9rYqAQztDjxFRwSJIiYB+z470Igw0t3VSFg4VQY3NKpP0
g1XIM320KquxHsDxY0jNw7ITTxYDIEzj+mbJYPgvO4coommUbuTfVInp/+a6jlXi
byiALmU4Ol8qv9vhU7FTaeQiC/TbVcwp8PF4rKGojb1CRg10vTDDFbZNkUCrZcSI
noZSGdzKgOymtUN/SQFnA83m19lAUJkjJnVfZ32JGCNq97oBiL9DmGDSHpCnhsl7
4eA9srwBuZmbS9cTJTCoMhKUpUq6DXI8yZ487jikrmtZTSrUD1reC27PK9heh/rE
DhFHwxwBAR3+gTbpBdU=
=7eiL
-----END PGP SIGNATURE-----

--2FkSFaIQeDFoAt0B--
