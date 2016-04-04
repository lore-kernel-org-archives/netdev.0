From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] irda: sh_irda: remove driver
Date: Mon, 04 Apr 2016 16:24:46 -0400 (EDT)
Message-ID: <20160404.162446.1948874932802627722.davem@davemloft.net>
References: <1459734279-6531-1-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, magnus.damm@gmail.com, netdev@vger.kernel.org,
	linux-renesas-soc@vger.kernel.org
To: horms+renesas@verge.net.au
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1459734279-6531-1-git-send-email-horms+renesas@verge.net.au>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Horman <horms+renesas@verge.net.au>
Date: Mon,  4 Apr 2016 10:44:39 +0900

> Remove the sh-irda driver as it appears to be unused since
> c0bb9b302769 ("ARCH: ARM: shmobile: Remove ag5evm board support").
> 
> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

Looks good, applied, thanks Simon.
