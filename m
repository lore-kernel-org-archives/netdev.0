From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V5 3/4] CS89x0 : remove QQ2440 board support from the
 CS89x0 driver
Date: Thu, 26 Jan 2012 17:50:14 -0500 (EST)
Message-ID: <20120126.175014.2206132443669941139.davem@davemloft.net>
References: <1327610831-26961-1-git-send-email-jaccon.bastiaansen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: fabio.estevam@freescale.com, linux@arm.linux.org.uk, netdev@vger.kernel.org,
 s.hauer@pengutronix.de, cavokz@gmail.com, kernel@pengutronix.de,
 u.kleine-koenig@pengutronix.de, festevam@gmail.com,
 linux-arm-kernel@lists.infradead.org
To: jaccon.bastiaansen@gmail.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1327610831-26961-1-git-send-email-jaccon.bastiaansen@gmail.com>
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

From: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
Date: Thu, 26 Jan 2012 21:47:11 +0100

> The QQ2440 board isn't supported anymore in the kernel, so support
> for this board can be removed from the CS89x0 driver.
> 
> Signed-off-by: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>

I'm fine with this going via one of the ARM trees:

Acked-by: David S. Miller <davem@davemloft.net>
