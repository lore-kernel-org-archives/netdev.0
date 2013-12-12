From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 1/2] drivers: net: cpsw: fix dt probe for one port ethernet
Date: Thu, 12 Dec 2013 13:41:11 +0530
Message-ID: <52A96F9F.7060801@ti.com>
References: <1386821345-30555-1-git-send-email-balbi@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	<netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux OMAP Mailing List <linux-omap@vger.kernel.org>
To: Felipe Balbi <balbi@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386821345-30555-1-git-send-email-balbi@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Balbi

On Thursday 12 December 2013 09:39 AM, Felipe Balbi wrote:
> From: Mugunthan V N <mugunthanvnm@ti.com>
>
> When only one port of the two port is pinned out, then dt probe is failing
> because second port phy is not found. fixing this by checking the number of
> slaves and breaking the loop.
>
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
> Signed-off-by: Felipe Balbi <balbi@ti.com>

This patch is already applied to net branch and its commit id is
3a27bfac17fe375539c4e0a53478679645eb5ae2.

Regards
Mugunthan V N
