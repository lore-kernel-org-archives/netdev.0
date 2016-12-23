From: David Miller <davem@davemloft.net>
Subject: Re: [patch net 0/3] mlxsw: Router fixes
Date: Fri, 23 Dec 2016 12:31:36 -0500 (EST)
Message-ID: <20161223.123136.1672408834618850953.davem@davemloft.net>
References: <1482481970-2327-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45686 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752974AbcLWRbi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2016 12:31:38 -0500
In-Reply-To: <1482481970-2327-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 23 Dec 2016 09:32:47 +0100

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Ido says:
> 
> First two patches ensure we remove from the device's table neighbours
> that are considered to be dead by the neighbour core.
> 
> The last patch removes nexthop groups from the device when they are no
> longer valid.

Series applied, thank you.
