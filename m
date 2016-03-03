From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sh_eth, ravb: Use ARCH_RENESAS
Date: Thu, 03 Mar 2016 17:10:04 -0500 (EST)
Message-ID: <20160303.171004.1302761225855181229.davem@davemloft.net>
References: <1456882093-2603-1-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, magnus.damm@gmail.com,
	netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: horms+renesas@verge.net.au
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1456882093-2603-1-git-send-email-horms+renesas@verge.net.au>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Horman <horms+renesas@verge.net.au>
Date: Wed,  2 Mar 2016 10:28:13 +0900

> Make use of ARCH_RENESAS in place of ARCH_SHMOBILE.
> 
> This is part of an ongoing process to migrate from ARCH_SHMOBILE to
> ARCH_RENESAS the motivation for which being that RENESAS seems to be a more
> appropriate name than SHMOBILE for the majority of Renesas ARM based SoCs.
> 
> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

Applied, thanks Simon.
