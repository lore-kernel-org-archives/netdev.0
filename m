From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 0/2] small set of sched cleanups
Date: Thu, 16 Mar 2017 12:02:51 -0700 (PDT)
Message-ID: <20170316.120251.2226435343527873265.davem@davemloft.net>
References: <1489661622-14498-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41000 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752119AbdCPTDR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 15:03:17 -0400
In-Reply-To: <1489661622-14498-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu, 16 Mar 2017 12:53:40 +0200

> Just two cleanups -- but for the 2nd one I think we need ack from 
> Cong Wang to make sure this isn't actually a bug report..
 ...
> changes from V1:
>   - addressed comment from Sergei to use 12 hex digits etc

Series applied since Eric Dumazet reviewed and ACK's patch #2,
although I still want Cong to take a look at it.

Thanks.
