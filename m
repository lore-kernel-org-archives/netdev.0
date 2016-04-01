From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mvpp2: fix maybe-uninitialized warning
Date: Fri, 01 Apr 2016 14:37:28 -0400 (EDT)
Message-ID: <20160401.143728.2154823165656728049.davem@davemloft.net>
References: <1459414883-6295-1-git-send-email-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mw@semihalf.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: jszhang@marvell.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459414883-6295-1-git-send-email-jszhang@marvell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jisheng Zhang <jszhang@marvell.com>
Date: Thu, 31 Mar 2016 17:01:23 +0800

> This is to fix the following maybe-uninitialized warning:
> 
> drivers/net/ethernet/marvell/mvpp2.c:6007:18: warning: 'err' may be
> used uninitialized in this function [-Wmaybe-uninitialized]
> 
> Signed-off-by: Jisheng Zhang <jszhang@marvell.com>

Applied.
