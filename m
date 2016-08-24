From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: phy: xgmiitorgmii: Fix non static symbol
 warning
Date: Tue, 23 Aug 2016 17:18:38 -0700 (PDT)
Message-ID: <20160823.171838.386599136081866354.davem@davemloft.net>
References: <1471964765-32708-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, michal.simek@xilinx.com,
        soren.brinkmann@xilinx.com, weiyongjun1@huawei.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56035 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752643AbcHXASj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 20:18:39 -0400
In-Reply-To: <1471964765-32708-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Tue, 23 Aug 2016 15:06:05 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Fixes the following sparse warning:
> 
> drivers/net/phy/xilinx_gmii2rgmii.c:61:5: warning:
>  symbol 'xgmiitorgmii_probe' was not declared. Should it be static?
> 
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Applied.
