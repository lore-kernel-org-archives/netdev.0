From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: hns: update the dependency
Date: Tue, 14 Jun 2016 22:26:13 -0700 (PDT)
Message-ID: <20160614.222613.1939489970427406792.davem@davemloft.net>
References: <1465818987-218513-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, charles.chenxin@huawei.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linuxarm@huawei.com
To: Yisen.Zhuang@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465818987-218513-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Date: Mon, 13 Jun 2016 19:56:27 +0800

> From: Kejian Yan <yankejian@huawei.com>
> 
> After the patchset about adding support of ACPI (commit id is 6343488)
> being applied, HNS does not depend on OF. It depends on OF or ACPI, so
> the Kconfig file needs to be updated.
> 
> Signed-off-by: Kejian Yan <yankejian@huawei.com>
> Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>

Why did you submit this same exact patch 3 times?
