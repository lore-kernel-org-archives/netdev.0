From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: tulip: remove deprecated IRQF_DISABLED
Date: Thu, 12 Sep 2013 23:27:44 -0400 (EDT)
Message-ID: <20130912.232744.661366284428853054.davem@davemloft.net>
References: <1378959624-4123-1-git-send-email-michael.opdenacker@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grundler@parisc-linux.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: michael.opdenacker@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1378959624-4123-1-git-send-email-michael.opdenacker@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Date: Thu, 12 Sep 2013 06:20:24 +0200

> This patch proposes to remove the IRQF_DISABLED flag from
> drivers/net/ethernet/dec/tulip/de4x5.c
> 
> It's a NOOP since 2.6.35 and it will be removed one day.
> 
> Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>

Applied.
