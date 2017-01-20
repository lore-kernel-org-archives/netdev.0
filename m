From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/5] net: ethernet: ti: cpsw: correct common res
 usage
Date: Fri, 20 Jan 2017 12:35:29 -0500 (EST)
Message-ID: <20170120.123529.686112420150314376.davem@davemloft.net>
References: <1484845107-30331-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, grygorii.strashko@ti.com,
        netdev@vger.kernel.org, linux-omap@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: ivan.khoronzhuk@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1484845107-30331-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Date: Thu, 19 Jan 2017 18:58:22 +0200

> This series is intended to remove unneeded redundancies connected with
> common resource usage function.
> 
> Since v1:
> - changed name to cpsw_get_usage_count()
> - added comments to open/closw for cpsw_get_usage_count()
> - added patch:
>   net: ethernet: ti: cpsw: clarify ethtool ops changing num of descs
> 
> Based on net-next/master

Series applied, thanks.
