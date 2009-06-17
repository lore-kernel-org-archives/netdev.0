From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC] net: refactor multicast/unicast address list
Date: Wed, 17 Jun 2009 11:30:24 +0200
Message-ID: <1245231024.19769.0.camel@johannes.local>
References: <1244889678.13033.6.camel@johannes.local>
	 <1244896094.13033.8.camel@johannes.local>
	 <20090616111842.GG3521@psychotron.englab.brq.redhat.com>
	 <1245151771.9256.3.camel@johannes.local>
	 <20090616123808.GK3521@psychotron.englab.brq.redhat.com>
	 <1245193788.21287.66.camel@johannes.local>
	 <20090617072100.GA3492@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-dnQ+/1+qJHfXXfhoj60i"
Cc: Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	davem <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090617072100.GA3492-YzwxZg+R7evSU73v1vjTzyO4YDw3rz4rAInAS/Ez/D0@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-dnQ+/1+qJHfXXfhoj60i
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2009-06-17 at 09:21 +0200, Jiri Pirko wrote:

> >I guess we could stick this one into wireless-testing, and then take it
> >out again once your patch hits the tree and offers me similar API for
> >list_head based multicast lists?
>=20
> Or wait, I hope the patch will be ready in week tops.

Yeah, that's fine, I'll ask people to throw in the simple export patch
for testing. Thanks for considering! Please disregard my work on
mac80211, I'll rebase over your work.

johannes

--=-dnQ+/1+qJHfXXfhoj60i
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKOLerAAoJEODzc/N7+Qma3PsQAI4I17KgsAViE89GdHtsAjPW
lNLvCqooQFQn3otyhJ4eQn+jNF/c83Vjz3m7KfTjQG8hC3I5vum8akEld5+eunPN
MT8GdLokKC7kpWLx7WyJYLiF1Puf9amUXsl/+HWUFG0wc9e/4pMIGe8OaDrEaAzW
hwBfpDp84Fm18+74QkjnPdumGuc+mG4m8TrETBXuPl+chb9Cnq007ObGqaAwPV7O
dIg1pTU8onPjmR/iryFw7Sn+jpHqQab9xqeSkwZFHR90o1OxARljkMOgjR49k8Mk
26lgzN4T6132SGQL7WlpUJ9JUkR+1xdZdZp9JPYMPP+PraPCJL3BoOMZiErRMRT/
qhMXmWo4QbpUm++ytAfdQDsByyBdbz1zLvrvnmBd7vnsT9sk5y74JUxt2BZg7b7D
jF8pHs3vJmqh/61tyBkcwXVMChBhu5TFdyykJUwXHk7wlyRlbQiZXchrZyl7+z0i
w72qwseisAk2MquQOQ00UYtP/90t2VANqQMoBdGg/W/GYwPy1p/s/UfHWKaGcTjG
zDnLhgsKYhR6LxlbgVlNGim0xXb6r0Il5b6v1NKDjAkjaVcA54dBK7CRA3Ecgs9T
Y54bFuKckvUeQQfpmhf5NVptFJ8JpdhAtlneZRgw9WGhuPdB9Hsf3Loeewl5D9cj
Qjd2r5ErfU6jkVscanlj
=oU1G
-----END PGP SIGNATURE-----

--=-dnQ+/1+qJHfXXfhoj60i--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
