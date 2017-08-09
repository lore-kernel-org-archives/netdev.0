From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net_sched: get rid of some forward
 declarations
Date: Tue, 08 Aug 2017 18:17:56 -0700 (PDT)
Message-ID: <20170808.181756.1584760492846856837.davem@davemloft.net>
References: <20170807222650.16561-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58444 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752222AbdHIBR4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 21:17:56 -0400
In-Reply-To: <20170807222650.16561-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon,  7 Aug 2017 15:26:50 -0700

> If we move up tcf_fill_node() we can get rid of these
> forward declarations.
> 
> Also, move down tfilter_notify_chain() to group them together.
> 
> Reported-by: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
