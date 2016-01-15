From: David Miller <davem@davemloft.net>
Subject: Re: [patch v3 net-next 0/2] dts: hisi: fixes no syscon fault when
 init mdio
Date: Fri, 15 Jan 2016 14:40:31 -0500 (EST)
Message-ID: <20160115.144031.1566053238441157328.davem@davemloft.net>
References: <1452668999-443-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	xuwei5@hisilicon.com, catalin.marinas@arm.com, will.deacon@arm.com,
	f.fainelli@gmail.com, andrew@lunn.ch, liguozhu@huawei.com,
	Yisen.Zhuang@huawei.com, sboyd@codeaurora.org,
	haojian.zhuang@linaro.org, wangzhou1@hisilicon.com,
	bintian.wang@huawei.com, long.wanglong@huawei.com,
	leo.yan@linaro.org, haifeng.wei@huawei.com,
	devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linuxarm@huawei.com
To: yankejian@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452668999-443-1-git-send-email-yankejian@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kejian Yan <yankejian@huawei.com>
Date: Wed, 13 Jan 2016 15:09:57 +0800

> This patchset fixes the bug that eth can't initial successful on hip05-D02
> because the dts files doesn't match the source code.

Series applied, thanks.
