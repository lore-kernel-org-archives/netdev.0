From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethernet: amd: remove deprecated IRQF_DISABLED
Date: Thu, 12 Sep 2013 23:27:35 -0400 (EDT)
Message-ID: <20130912.232735.548126572460523809.davem@davemloft.net>
References: <1378957970-3666-1-git-send-email-michael.opdenacker@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, benh@kernel.crashing.org,
	silviupopescu1990@gmail.com, geert@linux-m68k.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: michael.opdenacker@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1378957970-3666-1-git-send-email-michael.opdenacker@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Date: Thu, 12 Sep 2013 05:52:50 +0200

> This patch proposes to remove the IRQF_DISABLED flag from
> drivers/net/ethernet/amd/sun3lance.c
> 
> It's a NOOP since 2.6.35 and it will be removed one day.
> 
> Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>

Applied.
