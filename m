From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: hns: remove redundant dev_err call in
 hns_dsaf_get_cfg()
Date: Tue, 23 Aug 2016 17:18:31 -0700 (PDT)
Message-ID: <20160823.171831.1833534604549127414.davem@davemloft.net>
References: <1471965063-2494-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, salil.mehta@huawei.com,
        huangdaode@hisilicon.com, yankejian@huawei.com,
        xieqianqian@huawei.com, weiyongjun1@huawei.com,
        netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56022 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751032AbcHXASf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 20:18:35 -0400
In-Reply-To: <1471965063-2494-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Tue, 23 Aug 2016 15:11:03 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> There is a error message within devm_ioremap_resource
> already, so remove the dev_err call to avoid redundant
> error message.
> 
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Applied.
