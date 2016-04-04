From: Pali =?utf-8?B?Um9ow6Fy?= <pali.rohar@gmail.com>
Subject: Re: AP firmware for TI wl1251 wifi chip (wl1251-fw-ap.bin)
Date: Mon, 4 Apr 2016 14:39:44 +0200
Message-ID: <20160404123944.GA8413@pali>
References: <201603200040.26045@pali>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
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
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201603200040.26045@pali>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 20 March 2016 00:40:25 Pali Roh=C3=A1r wrote:
> Hi!
>=20
> In linux-firmware repository [1] is missing AP firmware for TI wl1251=
=20
> chip. There is only STA firmware wl1251-fw.bin which supports managed=
=20
> and ad-hoc modes.
>=20
> For other TI wilink chips there are <CHIP>-ap.bin firmware files=20
> (wl1271-fw-ap.bin and wl128x-fw-ap.bin) which support AP mode. But fo=
r=20
> wl1251 firmware file with guessed name "wl1251-fw-ap.bin" is missing.
>=20
> Do you have any idea what happened with AP firmware for ti wilink4=20
> wl1251 wifi chip? Or where can be found? Guys from TI, can you help?
>=20
> I see that STA firmware was added into linux-firmware tree in year 20=
13=20
> by this pull request [2].
>=20
> [1] - https://git.kernel.org/cgit/linux/kernel/git/firmware/linux-fir=
mware.git/tree/ti-connectivity
>=20
> [2] - http://thread.gmane.org/gmane.linux.kernel/1566500/focus=3D1571=
382
>=20

Hi! Anybody has some idea about that AP firmware?

--=20
Pali Roh=C3=A1r
pali.rohar@gmail.com
