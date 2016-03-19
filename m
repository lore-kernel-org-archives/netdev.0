From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: AP firmware for TI wl1251 wifi chip (wl1251-fw-ap.bin)
Date: Sun, 20 Mar 2016 00:40:25 +0100
Message-ID: <201603200040.26045@pali>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1977734.JuGmrhgnZ2";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: David Woodhouse <dwmw2@infradead.org>, Pavel Machek <pavel@ucw.cz>,
	Aaro Koskinen <aaro.koskinen@iki.fi>,
	Ben Hutchings <ben@decadent.org.uk>,
	David Gnedt <david.gnedt@platinumzone24.at>,
	Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
	Sebastian Reichel <sre@kernel.org>,
	Tony Lindgren <tony@atomide.com>, Nishanth Menon <nm@ti.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Luciano Coelho <coelho@ti.com>, Felipe Balbi <balbi@ti.com>,
	kev@ti.com, Shahar Levi <shahar_levi@ti.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	"Andrew F. Davis" <afd@ti.com>, Guy Mishol <guym@ti.com>,
	Yaniv Machani <yanivma@ti.com>, Arik Nemtsov <arik@wizery.com>,
	Gery Kahn <geryk@ti.com>, Felipe Balbi <balbi@kernel.org>,
	Luciano Coelho <luca@coelho.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:36193 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932426AbcCSXka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Mar 2016 19:40:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart1977734.JuGmrhgnZ2
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

Hi!

In linux-firmware repository [1] is missing AP firmware for TI wl1251=20
chip. There is only STA firmware wl1251-fw.bin which supports managed=20
and ad-hoc modes.

=46or other TI wilink chips there are <CHIP>-ap.bin firmware files=20
(wl1271-fw-ap.bin and wl128x-fw-ap.bin) which support AP mode. But for=20
wl1251 firmware file with guessed name "wl1251-fw-ap.bin" is missing.

Do you have any idea what happened with AP firmware for ti wilink4=20
wl1251 wifi chip? Or where can be found? Guys from TI, can you help?

I see that STA firmware was added into linux-firmware tree in year 2013=20
by this pull request [2].

[1] - https://git.kernel.org/cgit/linux/kernel/git/firmware/linux-firmware.=
git/tree/ti-connectivity

[2] - http://thread.gmane.org/gmane.linux.kernel/1566500/focus=3D1571382

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart1977734.JuGmrhgnZ2
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlbt42oACgkQi/DJPQPkQ1Kk8QCeNLTf1zNnP5r+0dw3BSShI4M6
3kIAn3a7na+8hx/8oVYIs+AIpeaG/mH6
=BVc0
-----END PGP SIGNATURE-----

--nextPart1977734.JuGmrhgnZ2--
