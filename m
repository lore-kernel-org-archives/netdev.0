From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/irda: convert drivers/net/irda/* to use
 module_platform_driver()
Date: Sun, 27 Nov 2011 20:29:25 -0500 (EST)
Message-ID: <20111127.202925.1652888847828501280.davem@davemloft.net>
References: <1322443443.2408.0.camel@phoenix>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kuninori.morimoto.gx@renesas.com,
	samuel@sortiz.org, netdev@vger.kernel.org
To: axel.lin@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1322443443.2408.0.camel@phoenix>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Axel Lin <axel.lin@gmail.com>
Date: Mon, 28 Nov 2011 09:24:03 +0800

> This patch converts the drivers in drivers/net/irda/* to use the
> module_platform_driver() macro which makes the code smaller and a bit
> simpler.
> 
> Cc: Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
> Signed-off-by: Axel Lin <axel.lin@gmail.com>
> ---
> v2: re-generate the patch against net-next tree.

Applied, thanks a lot.
