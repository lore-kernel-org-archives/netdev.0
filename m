From: David Miller <davem@davemloft.net>
Subject: Re: [patch net 0/2] net: sched: couple of chain fixes
Date: Tue, 22 Aug 2017 14:40:38 -0700 (PDT)
Message-ID: <20170822.144038.2239702270057480334.davem@davemloft.net>
References: <20170822204650.7016-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44760 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752303AbdHVVkj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 17:40:39 -0400
In-Reply-To: <20170822204650.7016-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 22 Aug 2017 22:46:48 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Jiri Pirko (2):
>   net: sched: fix use after free when tcf_chain_destroy is called
>     multiple times
>   net: sched: don't do tcf_chain_flush from tcf_chain_destroy

Series applied, thanks Jiri.
