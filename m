From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: natsemi: remove deprecated IRQF_DISABLED
Date: Mon, 16 Sep 2013 00:55:47 -0400 (EDT)
Message-ID: <20130916.005547.1189446138572216729.davem@davemloft.net>
References: <1379045813-6762-1-git-send-email-michael.opdenacker@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: michael.opdenacker@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1379045813-6762-1-git-send-email-michael.opdenacker@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Date: Fri, 13 Sep 2013 06:16:53 +0200

> This patch proposes to remove the IRQF_DISABLED flag from
> code in drivers/net/ethernet/natsemi/
> 
> It's a NOOP since 2.6.35 and it will be removed one day.
> 
> Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>

Applied.
