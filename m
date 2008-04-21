From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC: 2.6 patch] remove ieee80211_wx_{get,set}_auth()
Date: Mon, 21 Apr 2008 11:11:14 +0200
Message-ID: <1208769074.26186.53.camel@johannes.berg>
References: <20080421084834.GP26897@cs181133002.pp.htv.fi>
	 (sfid-20080421_094928_883145_7CB9F947)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-f1uKrp7pE/5qfJO77dNK"
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080421084834.GP26897-Aar9JVdAhcRoA3hw4S0G5QR5/fbUUdgG@public.gmane.org> (sfid-20080421_094928_883145_7CB9F947)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-f1uKrp7pE/5qfJO77dNK
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2008-04-21 at 11:48 +0300, Adrian Bunk wrote:
> After the bcm43xx removal ieee80211_wx_{get,set}_auth() were no longer=20
> used.
>=20
> Signed-off-by: Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
>=20
> ---
>=20
>  include/net/ieee80211.h      |    8 ---
>  net/ieee80211/ieee80211_wx.c |   89 -----------------------------------
>  2 files changed, 97 deletions(-)

Interesting. I thought those would have been in softmac, removal sounds
fine to me but I don't use the ieee80211 stack.

johannes

--=-f1uKrp7pE/5qfJO77dNK
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASAxaMaVg1VMiehFYAQKSRhAAnjEoNF4XRbwmO9J9NsZInLZ8dJTDTLM6
Mfjru3lrMuVq1CTl+EpnxRc0L1tigz3NCL/iei0y6GZi2sZq4+uiqHUIN/9KhgPQ
tH9hM5C+dnNJCIcs7V3YWXNV8uoMBZ1Ic7aDebK1YThuamhOc7lGs/Y3F+Ohwrym
WGOJ82n4K6fqx/jFtwOlSdnYG1Q0iVF8gv4D139AWRqqtP9KKOw+CtHrh83z2v7E
f2hPRfYE25WHKtEY136tH/wNHxIwS/vPdZSB7FGPuGppY1uQLtkeHs94QPW8pF99
sAmLhGZ/9Uwqhr5jaF7y1zWjryQvw616FramtVEVY1uU9Y0gNdPF4DX9W5jx9LG3
HgJuFM44ZUrncqNU154GYzs7i2s8dIdlVVz7wuyKJfBsHaiYUX3siHmS09Cx6Sv3
uRQtBx7htQ/9iPrKSjMYO+LgWp+fLGMiGWb1RGdgxvwWTWF/9mutHTZis5VQ4wxG
2pwxJpAR2mbIy4ywKGoSWUTmV5lClKUVHGMeuBVtoDlbQIDNuabUgpMTiC7P+Hs3
wvGZptvhJTCaONWHm+E5DVXhkOERFv2Iq2ZLvlEGUgiEMVIbsciTs3oaQwBlbfxp
ouNVtchSGXVsXz+n5xqtIsYeXOKkAq38hCMrvFtlYVqWoeKSScFPUUqoKOPUfR2G
pcLc3rS++q0=
=drvt
-----END PGP SIGNATURE-----

--=-f1uKrp7pE/5qfJO77dNK--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
