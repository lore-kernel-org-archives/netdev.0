From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: pull request: wireless-next-2.6 2009-02-23
Date: Mon, 23 Feb 2009 22:31:53 -0800
Message-ID: <1235457113.4455.89.camel@johannes.local>
References: <20090223192659.GB3553@tuxdriver.com>
	 (sfid-20090223_203027_265294_231D2366)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-vpFpMKN3DZUuZOMiaCd/"
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090223192659.GB3553-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> (sfid-20090223_203027_265294_231D2366)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-vpFpMKN3DZUuZOMiaCd/
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2009-02-23 at 14:26 -0500, John W. Linville wrote:

> Johannes Berg (10):
>       mac80211: disallow moving netns
>       mac80211: fix aggregation for hardware with ampdu queues
>       mac80211: split IBSS/managed code
>       genetlink: introduce pre/post methods

Hold off on this please, the genetlink patch here introduced a problem
with locking and I'm going to rework/fix that.

johannes

--=-vpFpMKN3DZUuZOMiaCd/
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJo5RXAAoJEKVg1VMiehFYmlkQALYaKEsjnHkCbd0yaDVVIHd/
v/YLEwLICJssImgY5GvB/RASOZc7mI7jpxVWywXLuRTtkGrv4+NJWdQwIeHnx5c8
LGgPWPBPRmvGLKg9j1E73Pg87mSCaAWOSzEFfqVkZzUxN/RRJCsjSBYcpa8eUxMo
+OfxUbKalZSw7cXHrz+rb+bFwacUV8Ng6t2nfnfsW7VTGr5DVfGPoewrwSMUDUhu
W2gIwqa+GAL/SFXSjy8+exCUD6DEqJw53JlQQUnvKTemekSfY0KJpzUDK9YYsA4x
VuMoM+Ut3+BlMp13ZgAyHABg2TJ5TXjSPAEr32taiRazg3MPwTMr2b2Sy4ZdsNiI
mn6qL0puQVzqZUAuDzksEMHNJ6OjEllb+S8RSfez3UbdDqIBS4YDKmQtf87KBvn2
lwGZBgXuNztBXijXEvUdkbHvfcYyAXZEK3VFVDJn7YBYRYQF2EmV0cMpV7QYothw
DB1UE3mkNypGsrr9mCbALi3JEjljC6CfXGfDt37qZRkymYxSg6uhJaZrHtpXoWbv
j/FxbovX3syzgBR10scrIvgbPYvyAJ8Cf4Wr1yNal/GXG5LZ8s6x1UIeqHcYvFwI
oTi8YKBnuo+FTEZyDmzIikCY7V3dmWpL0N3joz68pZ73THC22No55a5QhcTQ5J7G
yswhwInHjtFaOVi1RwJZ
=yL27
-----END PGP SIGNATURE-----

--=-vpFpMKN3DZUuZOMiaCd/--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
