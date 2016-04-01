From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mvpp2: use cache_line_size() to get cacheline size
Date: Fri, 01 Apr 2016 14:43:56 -0400 (EDT)
Message-ID: <20160401.144356.340761425248303262.davem@davemloft.net>
References: <1459501865-7033-1-git-send-email-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mw@semihalf.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	thomas.petazzoni@free-electrons.com
To: jszhang@marvell.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459501865-7033-1-git-send-email-jszhang@marvell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jisheng Zhang <jszhang@marvell.com>
Date: Fri, 1 Apr 2016 17:11:05 +0800

> L1_CACHE_BYTES may not be the real cacheline size, use cache_line_size
> to determine the cacheline size in runtime.
> 
> Signed-off-by: Jisheng Zhang <jszhang@marvell.com>
> Suggested-by: Marcin Wojtas <mw@semihalf.com>

Applied.
