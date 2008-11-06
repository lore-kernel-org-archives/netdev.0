From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] SSB: make it depend on PCI
Date: Thu, 06 Nov 2008 12:35:11 +0100
Message-ID: <1225971311.3619.214.camel@johannes.berg>
References: <1225965082-31462-1-git-send-email-vapier@gentoo.org>
	 <1225969620.3619.204.camel@johannes.berg>
	 <8bd0f97a0811060315j7d11e1a7p257a4a1bea640f7b@mail.gmail.com>
	 <1225970573.3619.208.camel@johannes.berg>
	 <8bd0f97a0811060326n5bcfc17fm5b5a65b12e71ea61@mail.gmail.com>
	 <1225970982.3619.211.camel@johannes.berg>
	 <8bd0f97a0811060332k281ae4d1m1fee62b27d811037@mail.gmail.com>
	 (sfid-20081106_123252_847507_66B0AD6D)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Orh9Qws4NIkET78xKnt5"
Cc: Mike Frysinger <vapier@gentoo.org>, Michael Buesch <mb@bu3sch.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Mike Frysinger <vapier.adi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:41366 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753659AbYKFLfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2008 06:35:15 -0500
In-Reply-To: <8bd0f97a0811060332k281ae4d1m1fee62b27d811037@mail.gmail.com> (sfid-20081106_123252_847507_66B0AD6D)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Orh9Qws4NIkET78xKnt5
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2008-11-06 at 06:32 -0500, Mike Frysinger wrote:

> > I guess we
> > need ifdefs or mandate that non-PCI architectures have dummy stubs (lik=
e
> > other architectures have in the !CONFIG_PCI case), but Michael's the SS=
B
> > expert.
>=20
> OK.  regarding the patch, if we drop the "&& PCI" part, i think the
> rest should get merged ... having empty menus in kconfig is annoying.
> agreed ?  i can send out another one ...

Yeah that part looks fine to me.

johannes

--=-Orh9Qws4NIkET78xKnt5
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJEtZqAAoJEKVg1VMiehFYN0gP/RQNaho+MDXPtCOP4uUdL3Kj
pDc+p5IiteBZPqMzjewjz0CjSw2yi0hX0QNTv6PWNuR/BV5auOmLZGkrvKvPDpTB
cQl929oYxsPKroYXOFYfgCYtWsb2+FsnGuVFZdtohUe0/qMwnkixj1HQUOm1EXgB
kKaeORT8hdIR1ee1voN4NRI7UZ3ynkdjLZineCcNG0G9Q5OGbrOpt8LTWuJzcN9+
JonpYernRTegdnJQnazh+5zKmvuvTtf3j1hlNR8RKHgACc8spQSoOw6QwjLmDpFn
Ws0tYIj16yH59VxEtB+i098gCXCn5Qnc07+NDKbSMtpVRX7tB2UiED0Ht21ChBI0
+hvNwlxYtrVTAFDx5gOpwJkm/giUb63HBVvfIt2LUqJKzFsog9+IqKrdksm/Z2OG
xGXi3n/IujTvA0CE2O6/Dwh4aqTmvZ187qNhL4EUGM89K397J/+SXugCq7BTmfRw
X06yxRRoaBDvxJdq/PyIavikalWzwpuOgHpSus8LXKQc1286sB6lFNcfF793fVk5
CVssmarQhoGNB8xOZ+r+FtixDw/HKVvqTlYw4QjEITeMjcbbcXiM4MXfduMPKQhd
Y0FNQFzeReZyvrQMYuIocglwUohSiVXProVj9tWi/ZoR0ScIT1xJTlEWOryzLo0/
LXr8dd8wR5TYZZtSQS8m
=FMSc
-----END PGP SIGNATURE-----

--=-Orh9Qws4NIkET78xKnt5--

