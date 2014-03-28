From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: sxgbe: fix sparse warnings about static
 declaration
Date: Fri, 28 Mar 2014 14:43:00 -0400 (EDT)
Message-ID: <20140328.144300.2043365269402850198.davem@davemloft.net>
References: <031b01cf4aaf$35e1b3b0$a1a51b10$@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org,
	fengguang.wu@intel.com, ks.giri@samsung.com,
	siva.kallam@samsung.com, vipul.pandya@samsung.com
To: bh74.an@samsung.com
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
In-Reply-To: <031b01cf4aaf$35e1b3b0$a1a51b10$@samsung.com>
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Byungho An <bh74.an@samsung.com>
Date: Fri, 28 Mar 2014 10:57:36 -0700

> From: Byungho An <bh74.an@samsung.com>
> 
> This fixes followings:
> 
> sparse warnings: (new ones prefixed by >>)
> 
>>> drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c:197:5: 
> sparse: symbol 'sxgbe_platform_freeze' was not declared. Should it be static?
>>> drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c:204:5: 
> sparse: symbol 'sxgbe_platform_restore' was not declared. Should it be static?
>>> drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c:228:24: 
> sparse: symbol 'sxgbe_platform_driver' was not declared. Should it be static?
> 
>>> drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c:1795:6: 
> sparse: symbol 'sxgbe_get_ops' was not declared. Should it be static?
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Byungho An <bh74.an@samsung.com>

Applied.
