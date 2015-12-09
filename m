From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: hns: optimize XGE capability by
 reducing cpu usage
Date: Tue, 08 Dec 2015 22:07:03 -0500 (EST)
Message-ID: <20151208.220703.17006788272368685.davem@davemloft.net>
References: <1449543751-131670-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lisheng011@huawei.com, lipeng321@huawei.com,
	salil.mehta@huawei.com, huangdaode@hisilicon.com,
	xuwei5@hisilicon.com, liguozhu@huawei.com, haifeng.wei@huawei.com,
	yisen.zhuang@huawei.com, linuxarm@huawei.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: yankejian@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449543751-131670-1-git-send-email-yankejian@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kejian Yan <yankejian@huawei.com>
Date: Tue, 8 Dec 2015 11:02:31 +0800

> here is the patch raising the performance of XGE by:
> 1)changes the way page management method for enet momery, and
> 2)reduces the count of rmb, and
> 3)adds Memory prefetching
> 
> Signed-off-by: Kejian Yan <yankejian@huawei.com>

Applied.
