From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ps3_gelic: remove deprecated IRQF_DISABLED
Date: Mon, 16 Sep 2013 00:56:08 -0400 (EDT)
Message-ID: <20130916.005608.2063539787734475811.davem@davemloft.net>
References: <1379046798-7192-1-git-send-email-michael.opdenacker@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: geoff@infradead.org, netdev@vger.kernel.org,
	cbe-oss-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
To: michael.opdenacker@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1379046798-7192-1-git-send-email-michael.opdenacker@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Date: Fri, 13 Sep 2013 06:33:18 +0200

> This patch proposes to remove the IRQF_DISABLED flag from
> drivers/net/ethernet/toshiba/ps3_gelic_net.c
> 
> It's a NOOP since 2.6.35 and I will remove it one day ;)
> 
> Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>

Applied.
