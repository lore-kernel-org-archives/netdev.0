From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: dsa: qca8k: fix non static symbol warning
Date: Thu, 22 Sep 2016 03:17:58 -0400 (EDT)
Message-ID: <20160922.031758.2203081583675563857.davem@davemloft.net>
References: <1474470283-31534-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john@phrozen.org, weiyongjun1@huawei.com, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56100 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750714AbcIVHSE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 03:18:04 -0400
In-Reply-To: <1474470283-31534-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Wed, 21 Sep 2016 15:04:43 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Fixes the following sparse warning:
> 
> drivers/net/dsa/qca8k.c:259:22: warning:
>  symbol 'qca8k_regmap_config' was not declared. Should it be static?
> 
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Applied.
