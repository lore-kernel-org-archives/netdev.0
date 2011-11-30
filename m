From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: fec: Select the FEC driver by default for i.MX
 SoCs
Date: Wed, 30 Nov 2011 17:08:10 -0500 (EST)
Message-ID: <20111130.170810.1453588817649945163.davem@davemloft.net>
References: <1322652717-2685-1-git-send-email-fabio.estevam@freescale.com>
 <1322664138-3245-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, marek.vasut@gmail.com,
 linux-arm-kernel@lists.infradead.org, kernel@pengutronix.de,
 u.kleine-koenig@pengutronix.de, shawn.guo@freescale.com
To: fabio.estevam@freescale.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1322664138-3245-1-git-send-email-fabio.estevam@freescale.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Fabio Estevam <fabio.estevam@freescale.com>
Date: Wed, 30 Nov 2011 12:42:18 -0200

> Since commit 230dec6 (net/fec: add imx6q enet support) the FEC driver is =
no =

> longer built by default for i.MX SoCs.
> =

> Let the FEC driver be built by default again.
> =

> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
> Suggested-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
> Acked-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de
> Acked-by: Shawn Guo <shawn.guo@linaro.org>

Applied.
