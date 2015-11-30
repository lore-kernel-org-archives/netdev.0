From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: What now when we're [almost] out of ADVERTISED bits?
Date: Mon, 30 Nov 2015 00:40:54 +0000
Message-ID: <1448844054.1990.32.camel@decadent.org.uk>
References: <CO2PR11MB00887F0A656EFB801BA2599797010@CO2PR11MB0088.namprd11.prod.outlook.com>
	 <CAJ3xEMj4ygmuSnxS-wkwukYyMgaA2omSQ+0MvY1MZKVv4_U6=A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-gdnOTtQYXZNpVavnoLTI"
Cc: netdev <netdev@vger.kernel.org>,
	David Decotigny <ddecotig@gmail.com>
To: Or Gerlitz <gerlitz.or@gmail.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:37650 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750938AbbK3AlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 19:41:07 -0500
In-Reply-To: <CAJ3xEMj4ygmuSnxS-wkwukYyMgaA2omSQ+0MvY1MZKVv4_U6=A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-gdnOTtQYXZNpVavnoLTI
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2015-11-29 at 23:39 +0200, Or Gerlitz wrote:
> On Sun, Nov 29, 2015 at 3:53 PM, Yuval Mintz <Yuval.Mintz@qlogic.com> wro=
te:
> > [I suspect there was probably some discussion over this,
> > but I couldn't find it; References would be welcome]
>=20
> there was a work by David Decotigny that should have solved the out of
> bits problem here [1]. Maybe it should be revived.
>=20
> [1] https://lkml.org/lkml/2015/1/26/882

Yes, it should.

Ben.

> > So it appears we're almost out of bits for new advertised speeds;
> > I'm currently looking at adding 100g.
> >=20
> > Assuming we want [and we do want] to have those in the `supported',
> > `advertising' and `lp_advertising' fields, the 2 reserve fields in
> > ethtool_cmd would not be sufficient [unless we break them into 4 u16].
> > Or are we planning something more generic than this for future bits?
>=20
> Or.
--=20
Ben Hutchings
Who are all these weirdos? - David Bowie, reading IRC for the first time
--=-gdnOTtQYXZNpVavnoLTI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVlubFue/yOyVhhEJAQr3KQ/+KqKq13UhX3TwLwkIL6DancKCrp8Pd6rX
8xeGsJYn+KaWihih+b6ukLbw6QmEV+sUfqhMuuhX+BsjCZTkiUi++X4SyDyRI9tn
ceiCV/pu0GJcU8mfQsWBmeAsztUQcIlH4rjkwVumLse8g0Z+GACnyNK/xSK/1Vyq
8LQ0ETk+Rc4UChF5bOU1L8y3H8CUUjSuTJf3CZ7Sm0PauOS7hQHXt+MRwSTTlYQ5
lVfxg+k3+dmKqYVT9oV3ctnXnztZ3CpPAhjRuRsL/24/kOhaqWMSnvGRdBl/uPyq
X6dZUCSk5HnGZMjtqC5BiaOuISHNO8kDNsAzRvXy3HxYEWYyYurQGlDG1Tu2zGY6
ZYFWPr0x2lQnYMGGhoI10S6GIrHlhlBY0c4orSpfohMyqV30QxhP8eE9/696LYlt
VMB9LYTqmMoGgPxfL20oYxtcwRnwFg/ooFhZXNoxf/GGKUUDd+qN5ohM15lFDdEk
UK5PaxDQ8Hd1s2DqKKegYpuaJ3Q+OoSFqAPK/5gCdWFgoPcZQOHlaDTWQ1AikA5d
4F7fNsDnFhFlPvEnZvYN8rxkuJwhkuHY5UkNbpZOmPKZZLpxq853iLWNp2Ijxej0
/iMsiShEI8FY/BqX5M64uufrN7YPFIlLMXJJzvzeNzUho6GvJtdjQZBmAPZFsDHL
lozDmFlVALQ=
=fF16
-----END PGP SIGNATURE-----

--=-gdnOTtQYXZNpVavnoLTI--
