From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] mlxsw: spectrum: Change ipv6 unregistered mc
 table
Date: Tue, 14 Feb 2017 13:16:35 -0500 (EST)
Message-ID: <20170214.131635.895852511182934791.davem@davemloft.net>
References: <1487016182-1896-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nogahf@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39126 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750930AbdBNSQh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 13:16:37 -0500
In-Reply-To: <1487016182-1896-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 13 Feb 2017 21:03:02 +0100

> From: Nogah Frankel <nogahf@mellanox.com>
> 
> Point back the unregister IPv6 mc table to the bc table.
> It is done since IPv6 mcast snooping is not supported for Spectrum yet.
> 
> Reported-by: Jiri Pirko <jiri@mellanox.com>
> Fixes: 71c365bdc439 ("mlxsw: spectrum: Separate bc and mc floods")
> Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
> Tested-by: Jiri Pirko <jiri@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied, thanks Jiri.
