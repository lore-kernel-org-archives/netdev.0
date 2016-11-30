From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] sched: cls_flower: remove from hashtable only in
 case skip sw flag is not set
Date: Tue, 29 Nov 2016 20:45:19 -0500 (EST)
Message-ID: <20161129.204519.1127685115175288472.davem@davemloft.net>
References: <1480344013-4812-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, idosch@mellanox.com,
        eladr@mellanox.com, ogerlitz@mellanox.com, hadarh@mellanox.com,
        amir@vadai.me
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39614 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754475AbcK3Bpl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 20:45:41 -0500
In-Reply-To: <1480344013-4812-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 28 Nov 2016 15:40:13 +0100

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Be symmetric to hashtable insert and remove filter from hashtable only
> in case skip sw flag is not set.
> 
> Fixes: e69985c67c33 ("net/sched: cls_flower: Introduce support in SKIP SW flag")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied, thanks Jiri.
