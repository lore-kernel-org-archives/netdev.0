From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ethernet: hisilicon: hns: use new api
 ethtool_{get|set}_link_ksettings
Date: Thu, 22 Sep 2016 02:12:08 -0400 (EDT)
Message-ID: <20160922.021208.47200652860650198.davem@davemloft.net>
References: <1474403412-18748-1-git-send-email-tremyfr@gmail.com>
        <1474403412-18748-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, salil.mehta@huawei.com,
        yankejian@huawei.com, huangdaode@hisilicon.com,
        lisheng011@huawei.com, xieqianqian@huawei.com, arnd@arndb.de,
        lipeng321@huawei.com, andrew@lunn.ch, chenny.xu@huawei.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55130 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755134AbcIVGMM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 02:12:12 -0400
In-Reply-To: <1474403412-18748-2-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Tue, 20 Sep 2016 22:30:12 +0200

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
