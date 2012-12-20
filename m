From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] build: unbreak linkage of m_xt.so
Date: Wed, 19 Dec 2012 16:03:17 -0800
Message-ID: <20121219160317.6004b55e@nehalam.linuxnetplumber.net>
References: <alpine.LNX.2.01.1212160119060.7193@nerf07.vanv.qr>
	<1355617968-26138-1-git-send-email-jengelh@inai.de>
	<20121218092130.1d3f4239@nehalam.linuxnetplumber.net>
	<201212181348.00379.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA256;
 boundary="Sig_/flAk.iQCe_8Z7DscS1pqkEQ"; protocol="application/pgp-signature"
Cc: Jan Engelhardt <jengelh@inai.de>, stephen.hemminger@vyatta.com,
	netdev@vger.kernel.org, jhs@mojatatu.com, urykhy@gmail.com,
	shemonc@gmail.com, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <201212181348.00379.vapier@gentoo.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/flAk.iQCe_8Z7DscS1pqkEQ
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 18 Dec 2012 13:47:58 -0500
Mike Frysinger <vapier@gentoo.org> wrote:

> this patch is no longer necessary one you merged my:
> 	configure: move toolchain init to a function
>=20
> it's actually undesirable to apply this after that since it makes the con=
figure=20
> script less clear again ...
>=20
> sorry if my commit message wasn't obvious.
> -mike

ok, went back to old way.

--Sig_/flAk.iQCe_8Z7DscS1pqkEQ
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQ0lXFAAoJEICnf2CVzeR+Gm0QAKOeChAt2VVMVhBWKeMMpfju
4v6UX++ZhcG1+rEyiaxsOLY3gzARf7ry+yF5rJdYzqLsug9+kUiGWrwYRVvNRdzi
8ViTISO2gg7Vefxf14lFejSL1y7ufBWZ+qDVYFe8DXV5L3sA+/j5YM/r3ZbV62QF
801rfKMp8G27+5fmzvN/ZU2onOFtmeoc2NK4LrKdTeZfzH5cLf3nmU6XvXTX9vRI
oV6trashd++Emg0GAqtfgd2A8P61shZhztSHRKvEFFGUoqjC09DT/o+PE0//JAyU
9C94Hx1GvUnmsiaNf4KhdHfKZkzdTzAf01wjZ4PxscFELyBfrEBwirJ0eGwPQi/+
u51jBoNjCWFWkEm7h0VUl9stKZYB+ybzGXtfctrdXI7D1/++gjSNlEE03x4vWjG/
XP4w/atoza7+ifi27I2CkuFakwPrnjmoAbwcqCmowSkYaRx+EhxvMOqkbNqtC6nn
enmc+Ra7EckxNFLw7EZP0tkkpiBsRz/gDEo+8IF3PKJXO0S1H3wx47VA3KtqZRyj
9A10dkAxxu89lirxYALYbhlQhKYPn86Bp1qCSXYe1aVH3Ramrr+As3vxeIZKsBI8
F3VvF5+rM/s//MaPQkS5uTndmIn6lsi+/edPWk/7I3FZmbVHnPI9+qUcbqbr7KPX
Ux1eAQHfdVyKnIrXW86V
=i96B
-----END PGP SIGNATURE-----

--Sig_/flAk.iQCe_8Z7DscS1pqkEQ--
