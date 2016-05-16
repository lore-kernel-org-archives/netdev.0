From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] net: pxa168_eth: improve performance
Date: Mon, 16 May 2016 13:40:14 -0400 (EDT)
Message-ID: <20160516.134014.1782979464569219380.davem@davemloft.net>
References: <1463140650-7038-1-git-send-email-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: jszhang@marvell.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463140650-7038-1-git-send-email-jszhang@marvell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jisheng Zhang <jszhang@marvell.com>
Date: Fri, 13 May 2016 19:57:28 +0800

> This series is to improve the pxa168_eth driver performance by using
> {readl|writel}_relaxed or appropriate memory barriers.

Applied.
