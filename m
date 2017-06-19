From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NET] net/hns:bugfix of ethtool -t phy self_test
Date: Mon, 19 Jun 2017 14:21:01 -0400 (EDT)
Message-ID: <20170619.142101.1820559309951882720.davem@davemloft.net>
References: <1497605091-94725-1-git-send-email-linyunsheng@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: huangdaode@hisilicon.com, xuwei5@hisilicon.com,
        liguozhu@hisilicon.com, Yisen.Zhuang@huawei.com,
        gabriele.paoloni@huawei.com, john.garry@huawei.com,
        linuxarm@huawei.com, salil.mehta@huawei.com, lipeng321@huawei.com,
        yankejian@huawei.com, tremyfr@gmail.com, xieqianqian@huawei.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linyunsheng@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36240 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751075AbdFSSVE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 14:21:04 -0400
In-Reply-To: <1497605091-94725-1-git-send-email-linyunsheng@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lin Yun Sheng <linyunsheng@huawei.com>
Date: Fri, 16 Jun 2017 17:24:51 +0800

> This patch fixes the phy loopback self_test failed issue. when
> Marvell Phy Module is loaded, it will powerdown fiber when doing
> phy loopback self test, which cause phy loopback self_test fail.
> 
> Signed-off-by: Lin Yun Sheng <linyunsheng@huawei.com>

Applied.
