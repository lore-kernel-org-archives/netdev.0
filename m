From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: phy: spi_ks8995: Introduce the use of
 devm_kzalloc
Date: Mon, 04 Aug 2014 12:55:43 -0700 (PDT)
Message-ID: <20140804.125543.174590535265021164.davem@davemloft.net>
References: <20140803080943.GA4323@himangi-Dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, paul.gortmaker@windriver.com,
	p.zabel@pengutronix.de, jg1.han@samsung.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	julia.lawall@lip6.fr
To: himangi774@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140803080943.GA4323@himangi-Dell>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Himangi Saraogi <himangi774@gmail.com>
Date: Sun, 3 Aug 2014 13:39:43 +0530

> This patch introduces the use of devm_kzalloc and does away with the
> kfrees in the probe and remove functions. Also, a label is removed.
> 
> Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
> Acked-by: Julia Lawall <julia.lawall@lip6.fr>

Applied, thank you.
