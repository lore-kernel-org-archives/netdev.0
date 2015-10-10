From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] net: hns: fix the unknown phy_nterface_t type
 error
Date: Sat, 10 Oct 2015 11:14:59 +0200
Message-ID: <20151010091459.GC2119@nanopsycho.orion>
References: <1444468838-59313-1-git-send-email-huangdaode@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, liguozhu@hisilicon.com,
	Yisen.Zhuang@huawei.com, netdev@vger.kernel.org,
	linuxarm@huawei.com, salil.mehta@huawei.com,
	kenneth-lee-2012@foxmail.com, xuwei5@hisilicon.com,
	lisheng011@huawei.com, linux-kernel@vger.kernel.org
To: huangdaode <huangdaode@hisilicon.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1444468838-59313-1-git-send-email-huangdaode@hisilicon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sat, Oct 10, 2015 at 11:20:38AM CEST, huangdaode@hisilicon.com wrote:
>This patch fix the building error reported by Jiri Pirko <jiri@resnulli.us>
>
>drivers/net/ethernet/hisilicon/hns/hnae.h:465:2: error: unknown type
>name 'phy_interface_t'
>        phy_interface_t phy_if;
>	^
>the full build log is on https://lists.01.org/pipermail/kbuild-all.
>
>Signed-off-by: huangdaode <huangdaode@hisilicon.com>
>Signed-off-by: yankejian <yankejian@huawei.com>

Reviewed-by: Jiri Pirko <jiri@mellanox.com>
