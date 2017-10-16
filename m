From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/9] net: sched: remove some tp->q usage
Date: Mon, 16 Oct 2017 21:01:00 +0100 (WEST)
Message-ID: <20171016.210100.1253627616514908067.davem@davemloft.net>
References: <20171013120105.23358-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34366 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754193AbdJPUBD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 16:01:03 -0400
In-Reply-To: <20171013120105.23358-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 13 Oct 2017 14:00:56 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> In order to prepare for block sharing, tcf_proto instances need to be
> independent on particular qdisc instances. This patchset takes care of
> removal of couple occurrences of tp->q usage.

Series applied, thanks Jiri.
