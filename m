From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: cpsw: drop IRQF_DISABLED
Date: Fri, 02 Aug 2013 14:54:07 -0700 (PDT)
Message-ID: <20130802.145407.1085542888053882863.davem@davemloft.net>
References: <1375429450-25454-1-git-send-email-balbi@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, netdev@vger.kernel.org,
	linux-omap@vger.kernel.org
To: balbi@ti.com
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1375429450-25454-1-git-send-email-balbi@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Felipe Balbi <balbi@ti.com>
Date: Fri, 2 Aug 2013 10:44:10 +0300

> IRQF_DISABLED is a no-op by now and should be
> removed.
> 
> Signed-off-by: Felipe Balbi <balbi@ti.com>

Applied.
