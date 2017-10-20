From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/sched: Set the net-device for egress
 device instance
Date: Fri, 20 Oct 2017 13:09:56 +0100 (WEST)
Message-ID: <20171020.130956.1734881299113022955.davem@davemloft.net>
References: <1508341088-20043-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mlxsw@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37198 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753006AbdJTMKA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 08:10:00 -0400
In-Reply-To: <1508341088-20043-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed, 18 Oct 2017 18:38:08 +0300

> Currently the netdevice field is not set and the egdev instance
> is not functional, fix that.
> 
> Fixes: 3f55bdda8df ('net: sched: introduce per-egress action device callbacks')
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> Acked-by: Jiri Pirko <jiri@mellanox.com>

Applied, thanks.
