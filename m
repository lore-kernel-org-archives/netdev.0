From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC v2] mac80211: assign needed_headroom/tailroom for netdevs
Date: Tue, 13 May 2008 12:07:33 +0200
Message-ID: <1210673253.3646.62.camel@johannes.berg>
References: <1209936745.7304.16.camel@johannes.berg>
	 <20080512.205224.12536510.davem@davemloft.net>
	 <1210669273.3646.51.camel@johannes.berg>
	 <20080513.024516.248213393.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Ej6wYmUCugoKRhhFgeIL"
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:49658 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752684AbYEMKHr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 06:07:47 -0400
In-Reply-To: <20080513.024516.248213393.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Ej6wYmUCugoKRhhFgeIL
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2008-05-13 at 02:45 -0700, David Miller wrote:
> From: Johannes Berg <johannes@sipsolutions.net>
> Date: Tue, 13 May 2008 11:01:13 +0200
>=20
> > Will you put in something like the patch that made dev_alloc_skb
> > reserve more with the bridging headroom as well, or do you want (me)
> > to look at routing first?
>=20
> I'm trying to do this one set of changes at a time. :-)
>=20
> I'll get to the netdev_alloc_skb() bits after this stuff
> has had some time to cook.

Sure, sounds good, thanks.

johannes

--=-Ej6wYmUCugoKRhhFgeIL
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASCloZKVg1VMiehFYAQI53Q//RkFGxtkBSPke7T2DolzEr1qQd/Qxr8xP
/xh1m38ZuOMMy552gg7XtTNfwUxs/wx50nP3pT81pa7iFSuNySPY1ooh1F4FmleY
MGC6IWLqBdPjAC1Y9lyNsii0LORpOi85H7tGnmVRUFsj5zIi/yjnvwgc7fXlMXEk
n/uqkoW4jDOR8xFvQbY0PlpcGd5w/tPsU/1eTghPqZ1HK5AHPd+tsFb/b00+rso7
pHevwpUN2+kpb8bqRM5W9a3Zk1yLFUpL1svdo2zXg//5tp33m+czwvZyhOkOW0GE
3KvICe+gEIANesxN++/OudNE4C+Ncm+S90ul2ii2pBwYLY28LliwiS+OqACYsjwM
mNfIm8oOEcDaOgW4KrtdJYIo/vH/fWReCe2UhxyqgPePobcoT4ttR9jhH6CKBGue
h/XzSLmwQXb94HISVAtmcKSr+sDOlTQtq3oMgwCc/34PuMTsTZV/fC3yZExILKd5
eyWTbYuOcRA1NsXKYprrimXQXeZ7yC/56Vn0UU0BPxYnrDXGVL8bvc+/oC/v80HF
LRa3MsUrmhyuL979bPL4T8wUaWoG3LhU4RSzOR79qUrzOgte+Dtipl1iYCCyhEp6
41V5XU0+gGlIFasJTOyB7sV0p+5jOZhQc1g2z78FC7Pg8wx3X9l6GWdh1X4irOp1
aKTlYOawjI4=
=xAz+
-----END PGP SIGNATURE-----

--=-Ej6wYmUCugoKRhhFgeIL--

