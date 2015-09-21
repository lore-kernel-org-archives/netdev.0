From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/5] net: Hisilicon Network Subsystem support
Date: Sun, 20 Sep 2015 21:44:21 -0700 (PDT)
Message-ID: <20150920.214421.16012758847156956.davem@davemloft.net>
References: <1442472710-20909-1-git-send-email-huangdaode@hisilicon.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	catalin.marinas@arm.com, will.deacon@arm.com,
	liguozhu@hisilicon.com, Yisen.Zhuang@huawei.com,
	paul.gortmaker@windriver.com, dingtianhong@huawei.com,
	zhangfei.gao@linaro.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, linuxarm@huawei.com,
	salil.mehta@huawei.com, kenneth-lee-2012@foxmail.com,
	xuwei5@hisilicon.com, lisheng011@huawei.com
To: huangdaode@hisilicon.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442472710-20909-1-git-send-email-huangdaode@hisilicon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: huangdaode <huangdaode@hisilicon.com>
Date: Thu, 17 Sep 2015 14:51:45 +0800

> This is V2 of Hisilicon Network Subsystem(HNS) patchesets taking care
> about LKML comments.
> 
> Please find out the changes from the change logs. 
> This patchset is rebased on mainline kernel Linux 4.3-rc1 branch.
> 
> [PATCH v2 1/5] Device Tree Binding Documentation
> [PATCH v2 2/5] Merge MDIO Module
> [PATCH v2 3/5] Hisilicon Network Acceleration Engine Framework
> [PATCH v2 4/5] Distributed System Area Fabric Module
> [PATCH v2 5/5] Basic Ethernet Driver Module
> 
> Changes from V1:
> 1. Remove "inline" in C file (according to LKML comment, same in below).
> 2. Fix a bug about class_find_device.
> 3. Change the DTS pattern on hnae, restruct it to compatible with Hi1610 soc.
> 4. Unified hip04_mdio and hip05_mdio into hns_mdio, which is more usaul for 
>    later SOCs.
> 
> V1 Patches Reference: https://lkml.org/lkml/2015/8/14/165

Series applied, thanks.

 
