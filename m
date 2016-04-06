From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: AP firmware for TI wl1251 wifi chip (wl1251-fw-ap.bin)
Date: Wed, 6 Apr 2016 14:12:43 +0200
Message-ID: <201604061412.43684@pali>
References: <201603200040.26045@pali> <20160404123944.GA8413@pali> <AE1C82FB3D0EC64DB1F752C81CBD1101390F6305@DFRE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart486655548.RrR3yeS5Ro";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Luciano Coelho <coelho@ti.com>, "Balbi, Felipe" <balbi@ti.com>,
	"Chalmers, Kevin" <kev@ti.com>, Shahar Levi <shahar_levi@ti.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	"Davis, Andrew" <afd@ti.com>, "Mishol, Guy" <guym@ti.com>,
	Arik Nemtsov <arik@wizery.com>, Gery Kahn <geryk@ti.com>,
	Felipe Balbi <balbi@kernel.org>,
	Luciano Coelho <luca@coelho.fi>,
	David Woodhouse <dwmw2@infradead.org>,
	Pavel Machek <pavel@ucw.cz>,
	"Aaro Koskinen" <aaro.koskinen@iki.fi>,
	Ben Hutchings <ben@decadent.org.uk>,
	"David Gnedt" <david.gnedt@platinumzone24.at>,
	Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
	Sebastian Reichel <sre@kernel.org>,
	"Tony Lindgren" <tony@atomide.com>, "Menon, Nishanth" <nm@ti.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Machani, Yaniv" <yanivma@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:33612 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932397AbcDFMMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 08:12:47 -0400
In-Reply-To: <AE1C82FB3D0EC64DB1F752C81CBD1101390F6305@DFRE01.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart486655548.RrR3yeS5Ro
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Wednesday 06 April 2016 13:30:22 Machani, Yaniv wrote:
> On Mon, Apr 04, 2016 at 15:39:44, Pali Roh=C3=A1r wrote:
> > > In linux-firmware repository [1] is missing AP firmware for TI
> > > wl1251 chip. There is only STA firmware wl1251-fw.bin which
> > > supports managed and ad-hoc modes.
> > >=20
> > > For other TI wilink chips there are <CHIP>-ap.bin firmware files
> > > (wl1271-fw-ap.bin and wl128x-fw-ap.bin) which support AP mode.
> > > But for
> > > wl1251 firmware file with guessed name "wl1251-fw-ap.bin" is
> > > missing.
> > >=20
> > > Do you have any idea what happened with AP firmware for ti
> > > wilink4 wl1251 wifi chip? Or where can be found? Guys from TI,
> > > can you help?
> > >=20
> > > I see that STA firmware was added into linux-firmware tree in
> > > year 2013 by this pull request [2].
> > >=20
> > > [1] -
> > > https://git.kernel.org/cgit/linux/kernel/git/firmware/linux-firmw
> > > are .g
> > > it/tree/ti-connectivity
> > >=20
> > > [2] -
> > > http://thread.gmane.org/gmane.linux.kernel/1566500/focus=3D1571382
> >=20
> > Hi! Anybody has some idea about that AP firmware?
>=20
> Hi,
> wl1251 does not support AP mode, so there is no firmware for it in
> the tree.
>=20
> Regards,
> Yaniv

Hi Yaniv! I read on some TI whitepaper, that wl1251 hardware supports=20
some Soft-AP mode. So I expect that either special FW is needed for it=20
or somehow it is possible to use current released. Do you have any=20
information about it?

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart486655548.RrR3yeS5Ro
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlcE/TsACgkQi/DJPQPkQ1I3MwCfcFf+Ruqa9/PWodjAIgALuoJl
g8AAoIo5sQ3QLS7E/EDKCRAenqGHhY+S
=hJlK
-----END PGP SIGNATURE-----

--nextPart486655548.RrR3yeS5Ro--
