From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH][NET] several cleanups and bugfixes for fec.c: preserve
 MII/RMII setting in fec_stop()
Date: Wed, 7 Dec 2011 21:37:45 +0800
Message-ID: <20111207133744.GR5550@S2100-06.ap.freescale.net>
References: <cover.1323163127.git.LW@KARO-electronics.de>
 <d6f4de9e4cfb393754b42815a2ef1a59c96eab83.1323163127.git.LW@KARO-electronics.de>
 <20111207094146.GG5550@S2100-06.ap.freescale.net>
 <20191.17172.493079.722098@ipc1.ka-ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, Shawn Guo <shawn.guo@linaro.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Lothar =?iso-8859-1?Q?Wa=DFmann?= <LW@KARO-electronics.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20191.17172.493079.722098@ipc1.ka-ro>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 07, 2011 at 11:42:28AM +0100, Lothar Wa=DFmann wrote:
> I'm using a TX28 which has the Ethernet PHY connected in RMII
> mode. You should see the problem, if you unplug the ethernet cable on
> a configured link. Without this patch the kernel will not detect when
> the cable is plugged back in.
>=20
Tested-by: Shawn Guo <shawn.guo@linaro.org>

--=20
Regards,
Shawn
