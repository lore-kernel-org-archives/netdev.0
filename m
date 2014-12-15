From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] net/macb: fix multiqueue support patch up
Date: Mon, 15 Dec 2014 11:51:08 -0500 (EST)
Message-ID: <20141215.115108.1859320509548372496.davem@davemloft.net>
References: <cover.1418651689.git.cyrille.pitchen@atmel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, soren.brinkmann@xilinx.com,
	linux-kernel@vger.kernel.org
To: cyrille.pitchen@atmel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1418651689.git.cyrille.pitchen@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cyrille Pitchen <cyrille.pitchen@atmel.com>
Date: Mon, 15 Dec 2014 15:13:30 +0100

> This series of patches is a fixup for the multiqueue support patch.
> 
> The first patch fixes a bug introduced by the multiqueue support patch.
> The second one doesn't fix a bug but simplify the source code by removing
> useless calls to devm_free_irq() since we use managed device resources for
> IRQs.
> 
> They were applied on the net-next tree and tested with a sama5d36ek board.

Series applied, thanks.
