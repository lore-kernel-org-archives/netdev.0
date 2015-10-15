From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: hisilicon: fixes a bug when using
 ethtool -S
Date: Thu, 15 Oct 2015 06:02:10 -0700 (PDT)
Message-ID: <20151015.060210.1389318547822520150.davem@davemloft.net>
References: <1444884034-113975-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: liguozhu@huawei.com, yisen.zhuang@huawei.com,
	huangdaode@hisilicon.com, lipeng321@huawei.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxarm@huawei.com
To: yankejian@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444884034-113975-1-git-send-email-yankejian@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: yankejian <yankejian@huawei.com>
Date: Thu, 15 Oct 2015 12:40:34 +0800

> From: lipeng <lipeng321@huawei.com>
> 
> this patch fixes a bug in hns driver. when we want to get statistic info
> by using ethtool -S, it shows us there are 3 wrong counters info. because
> the strings related to the registers are wrong. it needs to modify the
> strings which give us wrong info.
> 
> Signed-off-by: lipeng <lipeng321@huawei.com>
> Signed-off-by: yankejian <yankejian@huawei.com>
> Signed-off-by: Yisen Zhuang <yisen.zhuang@huawei.com>

Applied.
