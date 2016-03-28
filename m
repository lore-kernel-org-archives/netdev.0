From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] net: hns: set-coalesce-usecs returns
 errno by dsaf.ko
Date: Mon, 28 Mar 2016 11:39:43 -0400 (EDT)
Message-ID: <20160328.113943.1432536731823075776.davem@davemloft.net>
References: <1459161657-151406-1-git-send-email-Yisen.Zhuang@huawei.com>
	<1459161657-151406-3-git-send-email-Yisen.Zhuang@huawei.com>
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
In-Reply-To: <1459161657-151406-3-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Date: Mon, 28 Mar 2016 18:40:57 +0800

> From: Lisheng <lisheng011@huawei.com>
> 
> It may fail to set coalesce usecs to HW, and Ethtool needs to know if it
> is successful to cfg the parameter or not. So it needs return the errno by
> dsaf.ko.
> 
> Signed-off-by: Lisheng <lisheng011@huawei.com>
> Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>

Applied.
