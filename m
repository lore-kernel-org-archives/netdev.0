From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH/RFC] mac80211: convert to %pM away from print_mac
Date: Tue, 28 Oct 2008 09:07:24 +0100
Message-ID: <1225181244.3796.73.camel@johannes.berg>
References: <1224892243.3919.32.camel@johannes.berg>
	 <20081027.155243.206513005.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-QoJ9IJudhfVfx29+Vxap"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20081027.155243.206513005.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-QoJ9IJudhfVfx29+Vxap
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2008-10-27 at 15:52 -0700, David Miller wrote:
> From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> Date: Sat, 25 Oct 2008 01:50:43 +0200
>=20
> > Also remove a few stray DECLARE_MAC_BUF that were no longer
> > used at all.
> >=20
> > Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> > ---
> > Not sure this will apply to your tree, I prepared it against John's tre=
e
> > which might have more things. If you put the previous patch in, I
> > suppose John _could_ put it into his tree, but then he'd have to pull i=
n
> > yours which he normally doesn't... No idea. I can also just postpone
> > this?
>=20
> I munged this to apply to my tree, the only conflicts were in
> mlme.c

Yeah, that's the ones I had too.

> Sorry John, one of us had to deal with this :-)

John, you can always just take your version, and if I see print_mac show
up in mac80211 again then I'll send you another patch.

johannes

--=-QoJ9IJudhfVfx29+Vxap
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJBsg4AAoJEKVg1VMiehFYV+AQAIWphczN2nyxf+kCCFVp/F6D
ZrQMxHslMdkXUs22p15k5GyopaUDv2+2bUcnUZ/8mbjZxJy30+dmyJaYk8CunVPJ
AWCPcyDGmujA2y5XkOxvViXeAEChVHuJsOwsvtKX6mni4UWsNVRjF1OeQGmft/fP
fa84a0O1Iwb2UBvg5FJHEv/Nnym77JmkyZC3uMZD17bffkSgtNhRgQvhYkkcK+Fq
E6Mu3QEd2Cw9eDXul4QemzIwFw6MaxiwoaqJsVv2AIbnzgTMaN6ee3gnYELKQT8f
gK/GCRlLatC461QyMcknyZwY7mncwrI6A8hY2u0yNXwu/FOEINBTq5EOHPNBPNm9
eHbOG4Oh8zNaE0OiH4Lv6N7lNSCvlwkm0755fvzPJEIfF8LcMDHzJbVjLvACe9bT
dlpq3bvwdYeXP1/DYZiVN+zNQHK20zBq+JG1HMoa+/Fr04e8CFT2bwbe/kjwN2rg
O+yu4T9vn+DCSAdYIiInI2TN902X+OBMWsVNr752xyPCAs1kLs7+PvoLmjh4q4cI
rfmGdAdROv9QWkPh1uiFAI6wyb6JyYMbDykCk4kQjRjpWZbzZyBFpxlAxaZKK6tB
n4txkW4ZRH8KR2hp2CvQq526atyUvmr9GDxluLsIjNvjIY0yRzDl8AHek9n5p+wR
N15tFQyt725bW2g7rHnq
=KY62
-----END PGP SIGNATURE-----

--=-QoJ9IJudhfVfx29+Vxap--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
