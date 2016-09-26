From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] be2net: fix non static symbol warnings
Date: Sun, 25 Sep 2016 23:48:39 -0400 (EDT)
Message-ID: <20160925.234839.1674233846679773897.davem@davemloft.net>
References: <1474818036-18872-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sathya.perla@broadcom.com, ajit.khaparde@broadcom.com,
        sriharsha.basavapatna@broadcom.com, somnath.kotur@broadcom.com,
        weiyongjun1@huawei.com, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55258 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034719AbcIZDtE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 23:49:04 -0400
In-Reply-To: <1474818036-18872-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Sun, 25 Sep 2016 15:40:36 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Fixes the following sparse warnings:
> 
> drivers/net/ethernet/emulex/benet/be_main.c:47:25: warning:
>  symbol 'be_err_recovery_workq' was not declared. Should it be static?
> drivers/net/ethernet/emulex/benet/be_main.c:63:25: warning:
>  symbol 'be_wq' was not declared. Should it be static?
> 
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Applied.
