From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7] net: Fix module autoload for several platform
 drivers
Date: Mon, 17 Oct 2016 13:03:24 -0400 (EDT)
Message-ID: <20161017.130324.233185426125147662.davem@davemloft.net>
References: <1476713146-26632-1-git-send-email-javier@osg.samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, arnd@arndb.de, timur@codeaurora.org,
        noamca@mellanox.com, xieqianqian@huawei.com,
        vivien.didelot@savoirfairelinux.com, Lada.Trimasova@synopsys.com,
        huangdaode@hisilicon.com, sf84@laposte.net, f.fainelli@gmail.com,
        eladkan@mellanox.com, weiyongjun1@huawei.com,
        salil.mehta@huawei.com, yisen.zhuang@huawei.com, andrew@lunn.ch,
        yankejian@huawei.com, tremyfr@gmail.com, mans@mansr.com,
        netdev@vger.kernel.org, giladby@mellanox.com, jarod@redhat.com,
        oulijun@huawei.com
To: javier@osg.samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57894 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938553AbcJQRDe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 13:03:34 -0400
In-Reply-To: <1476713146-26632-1-git-send-email-javier@osg.samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Javier Martinez Canillas <javier@osg.samsung.com>
Date: Mon, 17 Oct 2016 11:05:39 -0300

> I noticed that module autoload won't be working in a bunch of platform
> drivers in the net subsystem and this patch series contains the fixes.

Looks good, series applied, thanks.
