From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH][NET] several cleanups and bugfixes for fec.c: set con_id
 in clk_get() call to NULL
Date: Wed, 7 Dec 2011 16:26:44 +0800
Message-ID: <20111207082643.GB5550@S2100-06.ap.freescale.net>
References: <cover.1323163127.git.LW@KARO-electronics.de>
 <6c28f25c5c6d2f88d0985ce361c5e16f19db27d0.1323163127.git.LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Shawn Guo <shawn.guo@linaro.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Lothar =?iso-8859-1?Q?Wa=DFmann?= <LW@KARO-electronics.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6c28f25c5c6d2f88d0985ce361c5e16f19db27d0.1323163127.git.LW@KARO-electronics.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 06, 2011 at 11:27:10AM +0100, Lothar Wa=DFmann wrote:
> The con_id is actually not needed for clk_get().
>=20
> Signed-off-by: Lothar Wa=DFmann <LW@KARO-electronics.de>

Other than subject,

Acked-by: Shawn Guo <shawn.guo@linaro.org>

--=20
Regards,
Shawn
