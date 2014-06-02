From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 v3] lpc_eth: Use resource_size instead of
 computation
Date: Mon, 02 Jun 2014 10:58:59 -0700 (PDT)
Message-ID: <20140602.105859.1728862913327118150.davem@davemloft.net>
References: <20140601.192705.693805935389177182.davem@davemloft.net>
	<20140602112419.GA3625@lip6.fr>
	<20140602113430.GA3823@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: benoit.taine@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140602113430.GA3823@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benoit Taine <benoit.taine@lip6.fr>
Date: Mon, 2 Jun 2014 13:34:30 +0200

> This issue was reported by coccicheck using the semantic patch 
> at scripts/coccinelle/api/resource_size.cocci
> 
> Signed-off-by: Benoit Taine <benoit.taine@lip6.fr>

This patch doesn't apply cleanly to any of my trees.
