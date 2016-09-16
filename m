From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: dsa: bcm_sf2: Fix non static symbol warning
Date: Fri, 16 Sep 2016 04:26:09 -0400 (EDT)
Message-ID: <20160916.042609.2285743999482928205.davem@davemloft.net>
References: <1473906253-1424-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, jiri@mellanox.com, weiyongjun1@huawei.com,
        netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38476 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751597AbcIPI0N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 04:26:13 -0400
In-Reply-To: <1473906253-1424-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Thu, 15 Sep 2016 02:24:13 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Fixes the following sparse warning:
> 
> drivers/net/dsa/bcm_sf2.c:963:19: warning:
>  symbol 'bcm_sf2_io_ops' was not declared. Should it be static?
> 
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Applied.
