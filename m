From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Linux Wireless Mini-Summit -- Ottawa -- July 22, 2008
Date: Wed, 16 Jul 2008 10:24:28 +0200
Message-ID: <1216196668.3422.2.camel@johannes.berg>
References: <20080709190915.GA8238@tuxdriver.com>
	 <247d6d340807140805gfb6523en74384f6f47469d79@mail.gmail.com>
	 <20080715174246.GA3117@tuxdriver.com>
	 <1216145731.13411.25.camel@localhost.localdomain>
	 (sfid-20080715_201731_895315_46FC8F2F)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-5SrjtC43sfUzGHmunCAn"
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Guy Cohen <guy@cguy.net>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:34303 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756671AbYGPIYx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 04:24:53 -0400
In-Reply-To: <1216145731.13411.25.camel@localhost.localdomain> (sfid-20080715_201731_895315_46FC8F2F)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-5SrjtC43sfUzGHmunCAn
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> > Not sure exactly what you mean with this one.  Are you talking about
> > the lib80211 line item?  Or enhancements to the mac80211 component
> > to support full(er) MAC designs?
>=20
> I hope just lib80211.  We shouldn't be extending mac80211 to fullmac or
> quasi-fullmac parts.  But we can certainly share a lot of stuff.
> lib80211 is where I see any additional fullmac effort going.

Just a minor point wrt. lib80211: I see little use in creating yet
another module since hopefully soon enough fullmac chipsets will bind
cfg80211 anyway so all of that stuff might as well be in there.

johannes

--=-5SrjtC43sfUzGHmunCAn
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJIfbA2AAoJEKVg1VMiehFYPUwQAIjia5olwIOp/+ZYuiQGEb4+
o2vuoBRTd8hcVAXR7SPj3vCPSA072Sgcfy7nxL1C8Wjj3BUKDrDd4s6+bFLE3TTd
lYbH59eh0OsMFdAZNrNwwGFsC+VpOtPGRqY0WfgeerhmbvkSXsWIcPd5c7kQ1S6v
pzcQ0ajWroOtaSn0+Ue+45uugAIDskexqA+WWbHPC15I3b2d7uSDUdBq2C3StlPj
IkK5g5Z/hlSGydPtutkeNsAkiml6VpfJJJLG1dRA99pcZThQwzxhFdhnKoneSnXb
PToADdr3LfmzOMQIJPjLGcrsnDyX+hkpXPARJXcu+BpnizA7lSkXXPw/Yq/sHQLA
g4r+nEUnPwkVUAUYJ9AfaVNAKB77sI8+yPxV0Gj8PynlkIkelc5oSYEWxC11yh49
cSrXeTwWO+YeuNacBx2BGykTxoSzeUQB9XVMUkyr4tqqvV1c7A/he4Q5PcIoM1RU
/Ns22DdqYHn1LRpwuCwdZkkks52ks7Cb6nsDq5cc5gd0ieFufTz3TxqfysLPDnWR
bWSxP3LIRsahzpM6czIPaG3WUufEocozPfN4c8BDaNjh3MIeU41xMXvSsgMKBjF/
8UQWYnjmeZNed5GlEd9+fYxVI9p/uJASoneX5WgbTQIUXEoX8rb+DaI7xJfQDeMt
g9pPFKlCvhO7aWzxKxq0
=BHM8
-----END PGP SIGNATURE-----

--=-5SrjtC43sfUzGHmunCAn--

