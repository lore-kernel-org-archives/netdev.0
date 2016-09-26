From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: dsa: mv88e6xxx: fix non static symbol
 warnings
Date: Sun, 25 Sep 2016 23:49:20 -0400 (EDT)
Message-ID: <20160925.234920.1663284215502440491.davem@davemloft.net>
References: <1474818182-19097-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, weiyongjun1@huawei.com,
        netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55276 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034719AbcIZDtY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 23:49:24 -0400
In-Reply-To: <1474818182-19097-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Sun, 25 Sep 2016 15:43:02 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Fixes the following sparse warnings:
> 
> drivers/net/dsa/mv88e6xxx/chip.c:219:5: warning:
>  symbol 'mv88e6xxx_port_read' was not declared. Should it be static?
> drivers/net/dsa/mv88e6xxx/chip.c:227:5: warning:
>  symbol 'mv88e6xxx_port_write' was not declared. Should it be static?
> 
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Applied.
