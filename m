From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] fsl/fman: fix error return code in mac_probe()
Date: Mon, 17 Oct 2016 13:17:05 -0400 (EDT)
Message-ID: <20161017.131705.1427013945307423818.davem@davemloft.net>
References: <1476717596-19526-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: madalin.bucur@nxp.com, weiyongjun1@huawei.com,
        netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58100 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932489AbcJQRRH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 13:17:07 -0400
In-Reply-To: <1476717596-19526-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Mon, 17 Oct 2016 15:19:56 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Fix to return a negative error code from the error handling
> case instead of 0, as done elsewhere in this function.
> 
> Fixes: 3933961682a3 ("fsl/fman: Add FMan MAC driver")
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Applied, thanks.
