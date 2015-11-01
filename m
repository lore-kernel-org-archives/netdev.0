From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: hisilicon: Remove .owner assignment from
 platform_driver
Date: Sun, 01 Nov 2015 16:04:11 -0500 (EST)
Message-ID: <20151101.160411.429478287834410453.davem@davemloft.net>
References: <1446173454-227326-1-git-send-email-huangdaode@hisilicon.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yankejian@huawei.com, yisen.zhuang@huawei.com,
	lisheng011@huawei.com, liguozhu@hisilicon.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: huangdaode@hisilicon.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446173454-227326-1-git-send-email-huangdaode@hisilicon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: huangdaode <huangdaode@hisilicon.com>
Date: Fri, 30 Oct 2015 10:50:54 +0800

> platform_driver doesn't need to set .owner, because
> platform_driver_register() will set it.
> 
> Signed-off-by: huangdaode <huangdaode@hisilicon.com>

Applied to net-next, thanks.
