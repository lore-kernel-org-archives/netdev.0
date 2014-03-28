From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: sxgbe: fix potential null dereference
Date: Fri, 28 Mar 2014 14:43:06 -0400 (EDT)
Message-ID: <20140328.144306.57938557700625418.davem@davemloft.net>
References: <031c01cf4aaf$3a4227a0$aec676e0$@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org,
	fengguang.wu@intel.com, ks.giri@samsung.com,
	siva.kallam@samsung.com, vipul.pandya@samsung.com
To: bh74.an@samsung.com
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
In-Reply-To: <031c01cf4aaf$3a4227a0$aec676e0$@samsung.com>
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Byungho An <bh74.an@samsung.com>
Date: Fri, 28 Mar 2014 10:57:44 -0700

> From: Byungho An <bh74.an@samsung.com>
> 
> This fixes following:
> 
> drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c:1828 sxgbe_hw_init()
> error: potential null dereference 'priv->hw'.  (kmalloc returns null)
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Byungho An <bh74.an@samsung.com>

Applied.
