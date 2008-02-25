From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] [PS3] gelic wireless driver needs MAC80211 support
Date: Mon, 25 Feb 2008 12:38:00 +0100
Message-ID: <1203939480.13162.98.camel@johannes.berg>
References: <20080223193517.GA6704@Chamillionaire.breakpoint.cc>
	 <47C0815F.7020100@pobox.com> <1203934436.13162.64.camel@johannes.berg>
	 <20080225111649.GA24352@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-DpEEszsZXEBwH0SGsDIJ"
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Masakazu Mokuno <mokuno@sm.sony.co.jp>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Sebastian Siewior <netdev@ml.breakpoint.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:38634 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753303AbYBYLir (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 06:38:47 -0500
In-Reply-To: <20080225111649.GA24352@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-DpEEszsZXEBwH0SGsDIJ
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


On Mon, 2008-02-25 at 12:16 +0100, Sebastian Siewior wrote:
> * Johannes Berg | 2008-02-25 11:13:56 [+0100]:
>=20
> >That seems completely wrong since it's a full-mac "chip" (implemented in
> >the HV or so maybe). What exactly does it need from mac80211?
> Nothing, please drop. I've sent another patch which enables WEXT what is
> the correct thing to do. Sorry for the noise.

No problem. I saw it later on netdev but had read linux-wireless
first :)

johannes

--=-DpEEszsZXEBwH0SGsDIJ
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR8Kol6Vg1VMiehFYAQKUSRAAiw8jPwhliNoXc/6K/BgKKW1SdJSSTJFY
9aCKn0v9Z4HCd4Ou1YWPe/MkzxBaKVmkLVX2a6vbyebQp3+zqY5HV4Hfi9IROvqT
sNyiUjOBO59AZxlF4BQ2xenZ0UiAbf4m/+QJOJqNkwLDtkl6l4HBF7/0vwc9Dahn
uumlkhRZIAC4VTwwtnBKXQg/9qnoCWYv3NDxFvPkTy4ba0ZMzPeTPKaJlXFpkh/o
eIDxSJ8F42FpgHGAitsQIayuaNefMjEJKrX4AiCMuz2Uep6ACyTzT8MFZ5WBYXM/
JWhEpeRBqHm5QQ9nLCPo5xcy2mXXcGMCvt20Hoiw/2wwaXA++aOwSnMz3E3yg/8H
HSnozG82b7APU9SG9dqoLv6cv+J5PEV7JrmTqbbd9UdREtFc2VksERW3YwgPGg3B
48FOJevm5OxJ9LLP6IVEjKSlA3vbV+JJrJGsGjnyyD4RZPBstcD4l+ASvWgZAEI8
quHRzVuou0d1/4apNlEf4TClF+rRuB5XgLdQgixDXdVUubUQt/HGf4Q2Ce3G6Imn
DZSNqgpVVl5IM5cANNNyYcFGiHGDkYvAlRC3XzsFsbo0wllC6rtQbdGIgN+3upuM
2cywBPGaduBCtkc74a+9bYzz1bUwTC9MXEUIsUs2bCY95cpYSyHGQQUEKZHah7vL
PcUlwa1X9AY=
=zLS/
-----END PGP SIGNATURE-----

--=-DpEEszsZXEBwH0SGsDIJ--

