From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 6/7] net: rfkill: gpio: add clock-frequency
 device tree property
Date: Tue, 15 Apr 2014 16:44:16 +0200
Message-ID: <20140415144416.GH3207@lukather>
References: <1397544101-18135-1-git-send-email-wens@csie.org>
 <1397544101-18135-7-git-send-email-wens@csie.org>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="4LFBTxd4L5NLO6ly"
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
Return-path: <linux-sunxi+bncBD2ZNBF5VYJRB4MLWWNAKGQE7GDCNAQ-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1397544101-18135-7-git-send-email-wens-jdAy2FN1RRM@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org


--4LFBTxd4L5NLO6ly
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Apr 15, 2014 at 02:41:40PM +0800, Chen-Yu Tsai wrote:
> Some devices, such as Broadcom Bluetooth devices, require a specific
> clock rate for the clock tied to the rfkill device. Add a clock-frequency
> property so we can specify this from the device tree.
>=20
> Signed-off-by: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>

I think such a property belongs to the device that requires it, and
not to the rfkill that controls it.

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com

--4LFBTxd4L5NLO6ly
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAEBAgAGBQJTTUXAAAoJEBx+YmzsjxAgsCUP/iA4SYjm+jYyJMCgApwwXNKw
w/VFkZpJUOm3raQQ/L+Xi2KSm4+xkXr7G3MbsIX1hkst2uuuOFUjSTsejkFrHbj2
hhH5cgZyag3qYI5ZYFxqF9kKpe0x7TdyWWGM9MMH3Gi2DgkwtnoA537XxSK8DRK7
mfczf7sIuimy/sqZugnYFntFw+r61jBz0NyG6C34tXYkyUHQwqVVKkCP+ev7d5j+
vgNXAgMNutArLpTVJtQcTDrRXgAmjx2jCVekk2+N4Xiv1Whil9uIZ93i99cMBJSR
72sDpenoaXYsBH5MZAusnxHwft/TFq/xlEVXvIwKHb3pn9JinbRNkMrN0rAFOCVM
MOIau7s1R2DrEjMEQGxrxQayjXbZWDsZu5Xv/OkRCSNK69dpL9Wpz/WHvwIhsvSy
EhW7DAztAiUMeYuc137Re68gU4VLCNrtRTe4UuZKwkW25ps9DJtrz4b6bqA/Ct/X
I4Fnuk/v0uY6VYW03gmJTF8Oa0bztz4tRcgirfZVzFvYjUBc0VQp9l6DcuBohi7k
DXZyQmCHq0x0AcVvxuiDi7GJ+sIJHbq8TBiaK2NbpzTJADlG0XN2vojfb0Jyr6jk
zv1qLqTCv40qt8xqiOoSolLcsYQZTjpd4t9y4oIyjKU8g874WpSDHlb7EXT01UYS
iA+4sA6cuZ/t/O3VwhpC
=ksvN
-----END PGP SIGNATURE-----

--4LFBTxd4L5NLO6ly--
