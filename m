From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 3/8] net: Add device tree support to LPC32xx
Date: Wed, 04 Apr 2012 04:39:52 -0400 (EDT)
Message-ID: <20120404.043952.1333187975072018080.davem@davemloft.net>
References: <1333528480-17134-1-git-send-email-stigge@antcom.de>
 <1333528480-17134-4-git-send-email-stigge@antcom.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: a.zummo@towertech.it, srinivas.bakki@nxp.com,
 linux-watchdog@vger.kernel.org, rtc-linux@googlegroups.com,
 gregkh@linuxfoundation.org, w.sang@pengutronix.de, kevin.wells@nxp.com,
 linux-kernel@vger.kernel.org, wim@iguana.be, arm@kernel.org,
 linux-i2c@vger.kernel.org, netdev@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, jonsmirl@gmail.com
To: stigge@antcom.de
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1333528480-17134-4-git-send-email-stigge@antcom.de>
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

From: Roland Stigge <stigge@antcom.de>
Date: Wed,  4 Apr 2012 10:34:35 +0200

> This patch adds device tree support for lpc_eth.c.
> 
> The runtime option for MII/RMII is solved via the "phy-mode" property, SRAM
> ("IRAM") usage for DMA can be chosen via "use-iram".
> 
> Signed-off-by: Roland Stigge <stigge@antcom.de>
> Reviewed-by: Arnd Bergmann <arnd@arndb.de>

Feel free to merge this in via one of the ARM trees.

Acked-by: David S. Miller <davem@davemloft.net>
