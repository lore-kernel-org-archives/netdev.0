From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] Fix up truesize after pskb_expand_head() in wireless
	stack
Date: Sun, 04 Jan 2009 18:33:08 +0100
Message-ID: <1231090388.3296.17.camel@johannes>
References: <20090104151819.GA6590@basil.nowhere.org>
	 <1231085150.3296.3.camel@johannes>
	 <20090104162826.GT496@one.firstfloor.org>
	 <1231087288.3296.15.camel@johannes>
	 <20090104174339.GX496@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-VZmzkUQHR0WHY9gWfu8M"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, davem <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090104174339.GX496-qrUzlfsMFqo/4alezvVtWx2eb7JE58TQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-VZmzkUQHR0WHY9gWfu8M
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2009-01-04 at 18:43 +0100, Andi Kleen wrote:

> > we need to do is figure out is why the skb has a wrong truesize.
>=20
> Because it was expanded without truesize being adjusted (see my
> original mail)=20

So why is this not making trouble with all the other users?

johannes

--=-VZmzkUQHR0WHY9gWfu8M
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJYPLRAAoJEKVg1VMiehFYhCcQAMM1Q5cs0I/SliK7q0NcReSk
UkS07dWgZCMFFoXAoWi0n6i+8mQapbbcpWIaRBQD1ClMAmYAxGxgWU0EuKqDyQHR
yznGCxdaJPsnLAV2YeS4uxywjce8YCnNJF8VbHnifSUfaDvrakIUEIbutwFaQpiP
1miqlflQKs5z2B8lyVHIuHelM4XUHttuk3KCUyax1XF8uX8+NNmiYwH+vCdtEjtF
pNqdBdbAcmUCeVG+UZLcR3+b5IsMNyvxMDg9G5aJfmOU+3JfrLcbB7hvmx9qMHp9
kDAQL3BFaOxBcxcQSFjCmUk/py5Uv3K7kKyf4WdvSTwczb1a6TCS2pO/GjMXQjkj
nbyQabhh69ocGwdtMW0NsB7KhfKdF8U04A77DSuvl5Kq5EpFFlPnsjvIguH2582i
eCCh0x/5t6k1uY7VrAN2v6q0EaTvI4rjynNPCCK4PzuqP3T9HKAeAKOIgjs6/G7B
wu53B3rGftMSH38fm0cLGbaEuOCe6Spbcm8tO7ZbvF82tP3VMPYt+KXhBpC7U7Bc
yo5njm8RO/xhjBDvw3X5PtH95JJQkYGPOmpBr72DmcgPo5kX1zgJ67Yqx7EE+p1T
3UBy+9IDmncxZkNK7Pbuyum93XCqJOdIq1bWQojnF/vSlVEB/8OB5LRJ+ONNB7/U
Vz2uF45v9EC3/NkepvKP
=3ew7
-----END PGP SIGNATURE-----

--=-VZmzkUQHR0WHY9gWfu8M--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
