From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/irda: convert drivers/net/irda/* to use
 module_platform_driver()
Date: Sun, 27 Nov 2011 17:15:05 -0500 (EST)
Message-ID: <20111127.171505.133514253141034705.davem@davemloft.net>
References: <1322402885.2746.1.camel@phoenix>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, ppopov@mvista.com,
	graf.yang@analog.com, kuninori.morimoto.gx@renesas.com,
	samuel@sortiz.org, netdev@vger.kernel.org
To: axel.lin@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1322402885.2746.1.camel@phoenix>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Axel Lin <axel.lin@gmail.com>
Date: Sun, 27 Nov 2011 22:08:05 +0800

> This patch converts the drivers in drivers/net/irda/* to use the
> module_platform_driver() macro which makes the code smaller and a bit
> simpler.
> 
> Cc: Pete Popov <ppopov@mvista.com>
> Cc: Graf Yang <graf.yang@analog.com>
> Cc: Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
> Signed-off-by: Axel Lin <axel.lin@gmail.com>

This doesn't apply cleanly to the net-next tree, please respin.
