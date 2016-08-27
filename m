From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: ethernet: ti: cpsw: fix error return code
 in cpsw_set_channels()
Date: Fri, 26 Aug 2016 21:50:08 -0700 (PDT)
Message-ID: <20160826.215008.1804199901151222246.davem@davemloft.net>
References: <1472222143-3604-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, grygorii.strashko@ti.com,
        ivan.khoronzhuk@linaro.org, weiyongjun1@huawei.com,
        linux-omap@vger.kernel.org, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34256 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751152AbcH0EuJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 Aug 2016 00:50:09 -0400
In-Reply-To: <1472222143-3604-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Fri, 26 Aug 2016 14:35:43 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Fix to return a negative error code from the cpsw_fill_rx_channels()
> error handling case instead of 0, as done elsewhere in this function.
> 
> Fixes: ce52c744574b ("net: ethernet: ti: cpsw: add ethtool channels support")
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Applied.
