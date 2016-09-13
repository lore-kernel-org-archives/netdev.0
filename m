From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: ethernet: dwmac: fix non static symbol
 warning
Date: Tue, 13 Sep 2016 11:43:02 -0400 (EDT)
Message-ID: <20160913.114302.647506594831247002.davem@davemloft.net>
References: <1473510690-25198-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        mcoquelin.stm32@gmail.com, weiyongjun1@huawei.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40230 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758087AbcIMPnD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 11:43:03 -0400
In-Reply-To: <1473510690-25198-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Sat, 10 Sep 2016 12:31:30 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Fixes the following sparse warning:
> 
> drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c:172:1: warning:
>  symbol 'stm32_dwmac_pm_ops' was not declared. Should it be static?
> 
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Applied.
