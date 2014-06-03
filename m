From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 v5] lpc_eth: Use resource_size instead of
 computation
Date: Tue, 03 Jun 2014 16:09:15 -0700 (PDT)
Message-ID: <20140603.160915.450521382704524671.davem@davemloft.net>
References: <20140602113430.GA3823@lip6.fr>
	<20140603103254.GA20794@lip6.fr>
	<20140603104559.GA21087@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: benoit.taine@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140603104559.GA21087@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benoit Taine <benoit.taine@lip6.fr>
Date: Tue, 3 Jun 2014 12:45:59 +0200

> This issue was reported by coccicheck using the semantic patch 
> at scripts/coccinelle/api/resource_size.cocci
> 
> Signed-off-by: Benoit Taine <benoit.taine@lip6.fr>

Applied, thanks.
