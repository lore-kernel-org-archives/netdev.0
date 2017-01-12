From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ravb: Remove Rx overflow log messages
Date: Thu, 12 Jan 2017 10:22:21 -0500 (EST)
Message-ID: <20170112.102221.792387985152329675.davem@davemloft.net>
References: <20170112122106.GA32727@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, magnus.damm@gmail.com,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: horms+renesas@verge.net.au
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20170112122106.GA32727@verge.net.au>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Horman <horms+renesas@verge.net.au>
Date: Thu, 12 Jan 2017 13:21:06 +0100

> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> 
> Remove Rx overflow log messages as in an environment where logging results
> in network traffic logging may cause further overflows.
> 
> Fixes: c156633f1353 ("Renesas Ethernet AVB driver proper")
> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> [simon: reworked changelog]
> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
> Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied, thanks.
