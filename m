From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v2 0/4] net_sched: clean up tc classes and u32
 filter
Date: Fri, 25 Aug 2017 17:20:40 -0700 (PDT)
Message-ID: <20170825.172040.116785180512101167.davem@davemloft.net>
References: <20170824235130.28503-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37094 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754462AbdHZAUl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 20:20:41 -0400
In-Reply-To: <20170824235130.28503-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Thu, 24 Aug 2017 16:51:26 -0700

> Patch 1 and patch 2 prepare for patch 3. Major changes
> are in patch 3 and patch 4, details are there too.
> 
> Cong Wang (4):
>   net_sched: get rid of more forward declarations
>   net_sched: introduce tclass_del_notify()
>   net_sched: remove tc class reference counting
>   net_sched: kill u32_node pointer in Qdisc
> 
> ---
> v2: Add patch 1 and 2, group all into a patchset
>     Fix a coding style issue in patch 4

Series applied, thanks.
