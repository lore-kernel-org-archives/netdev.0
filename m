From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: hns: add support of pause frame ctrl
 for HNS V2
Date: Sat, 02 Apr 2016 20:17:25 -0400 (EDT)
Message-ID: <20160402.201725.1897910785412352542.davem@davemloft.net>
References: <1459429209-230671-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: salil.mehta@huawei.com, liguozhu@huawei.com,
	huangdaode@hisilicon.com, arnd@arndb.de,
	andriy.shevchenko@linux.intel.com, andrew@lunn.ch,
	geliangtang@163.com, ivecera@redhat.com, lisheng011@huawei.com,
	fengguang.wu@intel.com, charles.chenxin@huawei.com,
	haifeng.wei@huawei.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxarm@huawei.com
To: Yisen.Zhuang@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459429209-230671-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Date: Thu, 31 Mar 2016 21:00:09 +0800

> From: Lisheng <lisheng011@huawei.com>
> 
> The patch adds support of pause ctrl for HNS V2, and this feature is lost
> by HNS V1:
>        1) service ports can disable rx pause frame,
>        2) debug ports can open tx/rx pause frame.
> 
> And this patch updates the REGs about the pause ctrl when updated
> status function called by upper layer routine.
> 
> Signed-off-by: Lisheng <lisheng011@huawei.com>
> Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
> Reviewed-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

Applied.
