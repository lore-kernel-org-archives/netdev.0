From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: hns: fixes the bug tested XGE by ethtool -p
Date: Tue, 27 Oct 2015 20:16:00 -0700 (PDT)
Message-ID: <20151027.201600.31952252291026853.davem@davemloft.net>
References: <1445937460-231548-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, lisheng011@huawei.com,
	lipeng321@huawei.com, salil.mehta@huawei.com,
	huangdaode@hisilicon.com, xuwei5@hisilicon.com,
	liguozhu@huawei.com, haifeng.wei@huawei.com, linuxarm@huawei.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: yankejian@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445937460-231548-1-git-send-email-yankejian@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: yankejian <yankejian@huawei.com>
Date: Tue, 27 Oct 2015 17:17:40 +0800

> From: Li Peng <lipeng321@huawei.com>
> 
> delete action of ETHTOOL_ID_ON/ETHTOOL_ID_OFF in XGE ethtool -p,
> so Hardware control the LED state instead of software.
> 
> Signed-off-by: Li Peng <lipeng321@huawei.com>
> Signed-off-by: Yisen Zhuang <yisen.zhuang@huawei.com>
> Signed-off-by: yankejian <yankejian@huawei.com>

Applied.
