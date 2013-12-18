From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] drivers: net cpsw: Enable In Band mode in cpsw for
 10 mbps
Date: Wed, 18 Dec 2013 16:54:47 -0500 (EST)
Message-ID: <20131218.165447.992468726225423101.davem@davemloft.net>
References: <1386940375-25168-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org
To: mugunthanvnm@ti.com
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1386940375-25168-1-git-send-email-mugunthanvnm@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Fri, 13 Dec 2013 18:42:55 +0530

> This patch adds support for enabling In Band mode in 10 mbps speed.
> RGMII supports 1 Gig and 100 mbps mode for Forced mode of operation.
> For 10mbps mode it should be configured to in band mode so that link
> status, duplexity and speed are determined from the RGMII input data
> stream
> 
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>

Applied, thanks.
