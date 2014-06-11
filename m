From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] net: sh_eth: Fix two issues in sh_eth_rx()
Date: Wed, 11 Jun 2014 15:15:55 -0700 (PDT)
Message-ID: <20140611.151555.814836065790733997.davem@davemloft.net>
References: <539653E4.9080808@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	sergei.shtylyov@cogentembedded.com
To: yoshihiro.shimoda.uh@renesas.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <539653E4.9080808@renesas.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Date: Tue, 10 Jun 2014 09:40:04 +0900

> I used the latest net.git repository.
>  commit id = 87757a917b0b3c0787e0563c679762152be81312
>  (net: force a list_del() in unregister_netdevice_many())
> 
> I tested these patches on r8a7790.
> 
> Changes from v1:
>  - Remove unnecessary parens in patch 1.

Applied, thanks.
