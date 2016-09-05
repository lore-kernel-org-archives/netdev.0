From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next v2] net: hns: fix return value check in
 hns_dsaf_get_cfg()
Date: Mon, 05 Sep 2016 12:43:13 -0700 (PDT)
Message-ID: <20160905.124313.2033920102101765222.davem@davemloft.net>
References: <1467644458-10131-1-git-send-email-weiyj_lk@163.com>
        <1467705412-30194-1-git-send-email-weiyj_lk@163.com>
        <F4CC6FACFEB3C54C9141D49AD221F7F91A6FA0CA@lhreml503-mbx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: weiyj_lk@163.com, yisen.zhuang@huawei.com, yankejian@huawei.com,
        yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: salil.mehta@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58256 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935431AbcIETnO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Sep 2016 15:43:14 -0400
In-Reply-To: <F4CC6FACFEB3C54C9141D49AD221F7F91A6FA0CA@lhreml503-mbx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Salil Mehta <salil.mehta@huawei.com>
Date: Mon, 5 Sep 2016 14:20:33 +0000

> This patch will conflict with Doug Ledford's hns-roce's HNS driver.
> This might lead to problems later during this merge window of 4.9.

You don't need to say this three times.

These changes will not be reverted, instead the conflicts will need
to simply be resolved during the merges just like any other conflict
that ever happens in our trees.
