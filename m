From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-05-28
Date: Thu, 29 May 2008 09:33:58 +0200
Message-ID: <1212046438.16917.0.camel@johannes.berg>
References: <20080528213831.GA3133@tuxdriver.com>
	 <1212012670.21624.48.camel@johannes.berg>
	 <20080529003527.GC22536@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-i6oqQJ0OexmjRAbRaIyB"
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080529003527.GC22536-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-i6oqQJ0OexmjRAbRaIyB
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2008-05-28 at 20:35 -0400, John W. Linville wrote:
> On Thu, May 29, 2008 at 12:11:10AM +0200, Johannes Berg wrote:
> > On Wed, 2008-05-28 at 17:38 -0400, John W. Linville wrote:
> > > David,
> > >=20
> > > Another round of fixes for 2.6.26 follows...
> > >=20
> > > Please let me know if there are problems!
> >=20
> > What about
> >=20
> > [PATCH] b43legacy: fix build errors when DMA or PIO are not selected
>=20
> That claims to correct a problem created by "mac80211: move TX info
> into skb->cb", which is not in the 2.6.26 stream.  I will apply it
> to wireless-next-2.6.

Sorry, yes, my mistake.

johannes

--=-i6oqQJ0OexmjRAbRaIyB
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASD5cZaVg1VMiehFYAQIGXQ/+NCdC7oaAquqd19vCct1J3a0A7eFnfP8W
xvxU38/970D8l75DABrHixaupJOKz1WpnM6UCobzSZhy0y/OAUe6MbEFBt3efKvB
fn6l1Yti4NoD6xNtgFcqB+wPlP0nXVaXw83++C2FKDQ6VjbBdecnCDRBesex1jBX
wPjeWpT57eDonUHG5I+Zoeues92ffAP4zIjK9/mAKGPVUMVsQ84+XGK6/xllMYXj
+HoTR1H/V6y1xjILEUaIYZ9Mm/PznFgOPtAXoFPIR5mIGEgsYrvy58RYy6tfuh/Z
ewLTv+G6i+D0+KEGtQToQrDBb2I3UXo9OKR4uEJqW6Eg96tvQ5Z2PT9i+r6BitUx
cfNPr8k+XssP8STSbGkANyT+wQOeNmizXIhvwVP+xKD+ljHQsunJHEtJLKoTO4vy
e7s5UI4kTtO6H5Yadn5UhifgVmbo8KmXWPtA2nn6wyO31jmUM3gEfJxSY4Kd7A8Y
eU2uh5iHqRuzfkQ8pPUnCc52+NIDv4NKefvJuO5wqa/YM1VKKJebmyTSXe+GNXvN
CwT4TGij1C0J5Qqxm9VlKR71548OYUVvIhdhdFTZUSYgQaVbFM1V8bsiJLvQ1iHp
T3FxgVjdBZvdXAGJSHMFOsqsVouhoBg+OcSKeLiUFbPf9/OhbHn0Hq9DIWAbBiLE
x0HB0K74gk0=
=KKsA
-----END PGP SIGNATURE-----

--=-i6oqQJ0OexmjRAbRaIyB--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
