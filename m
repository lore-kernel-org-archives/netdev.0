From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: hisilicon net: fix a bug about led
Date: Wed, 14 Oct 2015 18:42:11 -0700 (PDT)
Message-ID: <20151014.184211.1364291270850334945.davem@davemloft.net>
References: <1444789737-25428-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: liguozhu@huawei.com, yisen.zhuang@huawei.com,
	huangdaode@hisilicon.com, lipeng321@huawei.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxarm@huawei.com
To: yankejian@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444789737-25428-1-git-send-email-yankejian@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: yankejian <yankejian@huawei.com>
Date: Wed, 14 Oct 2015 10:28:57 +0800

> From: lipeng <lipeng321@huawei.com>
> 
> this patch fixes a bug in hns driver. the link led is on at the beginning,
> but at this time the ethernet port is on down status. it needs to reset
> the led status on init sequence.
> 
> Signed-off-by: lipeng <lipeng321@huawei.com>
> Signed-off-by: yankejian <yankejian@huawei.com>

Applied.
