From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 0/4] net: sched: get rid of
 cls_flower->egress_dev
Date: Wed, 11 Oct 2017 20:15:57 -0700 (PDT)
Message-ID: <20171011.201557.1830627406292467709.davem@davemloft.net>
References: <20171011074110.2800-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        saeedm@mellanox.com, matanb@mellanox.com, leonro@mellanox.com,
        mlxsw@mellanox.com, David.Laight@ACULAB.COM, gerlitz.or@gmail.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42004 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752029AbdJLDP6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 23:15:58 -0400
In-Reply-To: <20171011074110.2800-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 11 Oct 2017 09:41:06 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Introduction of cls_flower->egress_dev was a workaround. Turned out
> to be a bit ugly hack. So replace it with more generic and reusable
> infrastructure.
> 
> This is a dependency of shared block introduction that will be send as
> a follow-up patchsets group.

Series applied, thanks.
