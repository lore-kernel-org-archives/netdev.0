From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bcm63xx_enet: remove deprecated IRQF_DISABLED
Date: Wed, 11 Sep 2013 16:15:05 -0400 (EDT)
Message-ID: <20130911.161505.542945565529627644.davem@davemloft.net>
References: <1378537010-7128-1-git-send-email-michael.opdenacker@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jogo@openwrt.org, joe@perches.com, jg1.han@samsung.com,
	mbizon@freebox.fr, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: michael.opdenacker@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1378537010-7128-1-git-send-email-michael.opdenacker@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Date: Sat,  7 Sep 2013 08:56:50 +0200

> This patch proposes to remove the IRQF_DISABLED flag from
> drivers/net/ethernet/broadcom/bcm63xx_enet.c
> 
> It's a NOOP since 2.6.35 and it will be removed one day.
> 
> Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>

Applied.
