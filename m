From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: hns: fix the unknown phy_nterface_t type
 error
Date: Mon, 12 Oct 2015 19:46:57 -0700 (PDT)
Message-ID: <20151012.194657.1983469628421104487.davem@davemloft.net>
References: <1444468838-59313-1-git-send-email-huangdaode@hisilicon.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, liguozhu@hisilicon.com, Yisen.Zhuang@huawei.com,
	netdev@vger.kernel.org, linuxarm@huawei.com,
	salil.mehta@huawei.com, kenneth-lee-2012@foxmail.com,
	xuwei5@hisilicon.com, lisheng011@huawei.com,
	linux-kernel@vger.kernel.org
To: huangdaode@hisilicon.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444468838-59313-1-git-send-email-huangdaode@hisilicon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: huangdaode <huangdaode@hisilicon.com>
Date: Sat, 10 Oct 2015 17:20:38 +0800

> This patch fix the building error reported by Jiri Pirko <jiri@resnulli.us>
> 
> drivers/net/ethernet/hisilicon/hns/hnae.h:465:2: error: unknown type
> name 'phy_interface_t'
>         phy_interface_t phy_if;
> 	^
> the full build log is on https://lists.01.org/pipermail/kbuild-all.
> 
> Signed-off-by: huangdaode <huangdaode@hisilicon.com>
> Signed-off-by: yankejian <yankejian@huawei.com>

Applied, thanks.
