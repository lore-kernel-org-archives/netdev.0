From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net_sched: nla_memdup_cookie() can be static
Date: Tue, 14 Feb 2017 15:02:34 -0500 (EST)
Message-ID: <20170214.150234.1161025224187495564.davem@davemloft.net>
References: <20170214141932.15115-1-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, weiyongjun1@huawei.com, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42022 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752604AbdBNUCg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 15:02:36 -0500
In-Reply-To: <20170214141932.15115-1-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Tue, 14 Feb 2017 14:19:32 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Fixes the following sparse warning:
> 
> net/sched/act_api.c:532:5: warning:
>  symbol 'nla_memdup_cookie' was not declared. Should it be static?
> 
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Applied, thank you.
