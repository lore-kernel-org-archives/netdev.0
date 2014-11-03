From: Christian Hesse <mail@eworm.de>
Subject: Re: [PATCH v4 1/1] ip-link: add switch to show human readable
 output
Date: Mon, 3 Nov 2014 07:53:15 +0100
Message-ID: <20141103075315.0045d214@leda.localdomain>
References: <20141031123115.4cd13371@urahara>
	<1414791193-25192-1-git-send-email-mail@eworm.de>
	<20141102125159.02efa974@urahara>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/0YGGds4JK2/p1VmE8nlbqFe"; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.mylinuxtime.de ([148.251.109.235]:47053 "EHLO
	mx.mylinuxtime.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750739AbaKCGxZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 01:53:25 -0500
In-Reply-To: <20141102125159.02efa974@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/0YGGds4JK2/p1VmE8nlbqFe
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Stephen Hemminger <stephen@networkplumber.org> on Sun, 2014/11/02 12:51:
> On Fri, 31 Oct 2014 22:33:13 +0100
> Christian Hesse <mail@eworm.de> wrote:
>=20
> > Byte and packet count can increase to really big numbers. This adds a
> > switch to show human readable output.
> >=20
> > 4: wl: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode
> > DORMANT group default qlen 1000 link/ether 00:de:ad:be:ee:ef brd
> > ff:ff:ff:ff:ff:ff RX: bytes  packets  errors  dropped overrun mcast
> >     1523846973 3969051  0       0       0       0
> >     TX: bytes  packets  errors  dropped carrier collsns
> >     8710088361 6077735  0       0       0       0
> > 4: wl: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode
> > DORMANT group default qlen 1000 link/ether 00:de:ad:be:ee:ef brd
> > ff:ff:ff:ff:ff:ff RX: bytes  packets  errors  dropped overrun mcast
> >     1.5G       3.9M     0       0       0       0
> >     TX: bytes  packets  errors  dropped carrier collsns
> >     8.7G       6.0M     0       0       0       0
>=20
> Applied, then I did a code cleanup and added -iec as a option (similar to
> tc).

I would have come up with something similar later. ;) Thanks a lot!
I am perfectly happy now and can live without ifconfig in the future.
--=20
Best regards,
Christian Hesse

--Sig_/0YGGds4JK2/p1VmE8nlbqFe
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUVyZeAAoJEFTtyRYJvJGDNIcP/2E8kN6IX7oNJ2gCJ9jb8zgE
v7awZUL+c0HCylGFNWqgNUa+QbbH8GMNS12YL///tStzZywoMQRuJEybBr0hwEHI
avqTBy41iuMV56/1nMeK9oLJSl82+Fhm0bFlWLYsDqlktPH4dm5LOIHpiBmEaoIy
zP2LmTQlxABUZw12AJ0FXLWDF1q8HXpsjrbBHvSz87YC1/Bs5y/+sJc+cfcUTVvB
Mt+vB5wTzoepLbvKhdt8WCtUM8HJo/9eQT9z3mCVcaZJG5Hw2Pe3jIjqjhTaOGX6
oPKlMn6WLK9IY0ji13NssYXLNcg/EEtzdZJr6l86UQbYidRM8l5wrOyv3FvQvv8v
6VgthlSzuP6txfNiGkmZrEcDeT7x/RgEDYQPMVNJKDT4LXNQGyLxtvBgEiXwpkVW
txhxKo+FmiA5TlFTsl8WFKu/HjG4aaV9kLuRhJZE8+/2TU3WaX3iesEdFiuWJvZ3
mqN2XfMG7inodWhtN1eduIXpnoEGGaru8qUr231JdTq7ofChBP2KjQfTuouubBgC
OmJOzjh96LDXOiaSqFekCqw2shG+CpX6LcxqmLtvrb64/s61VkHVnZUwbTEvj4SC
OXkhhX8+Nqcfot1bxJAgA70/XyTn9Vo3nSKjCA5cTV3UOq8g968bYQa81DMvY9w8
XC6toZAFAtOhuhq3sR3i
=HFuf
-----END PGP SIGNATURE-----

--Sig_/0YGGds4JK2/p1VmE8nlbqFe--
