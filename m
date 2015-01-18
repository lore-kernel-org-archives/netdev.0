From: David Miller <davem@davemloft.net>
Subject: Re: [patch-net-next v3 1/2] net: ethernet: cpsw: unroll IRQ
 request loop
Date: Sun, 18 Jan 2015 01:07:45 -0500 (EST)
Message-ID: <20150118.010745.445135269292684453.davem@davemloft.net>
References: <1421424672-19323-1-git-send-email-balbi@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tony@atomide.com, linux-omap@vger.kernel.org, mugunthanvnm@ti.com,
	netdev@vger.kernel.org
To: balbi@ti.com
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1421424672-19323-1-git-send-email-balbi@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Felipe Balbi <balbi@ti.com>
Date: Fri, 16 Jan 2015 10:11:11 -0600

> This patch is in preparation for a nicer IRQ
> handling scheme where we use different IRQ
> handlers for each IRQ line (as it should be).
> 
> Later, we will also drop IRQs offset 0 and 3
> because they are always disabled in this driver.
> 
> Signed-off-by: Felipe Balbi <balbi@ti.com>

Applied.
