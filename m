From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] mlxsw: spectrum_router: Don't batch neighbour
 deletion
Date: Mon, 24 Jul 2017 16:17:41 -0700 (PDT)
Message-ID: <20170724.161741.2070174806443778678.davem@davemloft.net>
References: <20170721183138.23505-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44500 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932294AbdGXXRm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 19:17:42 -0400
In-Reply-To: <20170721183138.23505-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 21 Jul 2017 20:31:38 +0200

> From: Ido Schimmel <idosch@mellanox.com>
> 
> Current firmware supported by the driver doesn't support batch deletion
> of IPv6 neighbours on a given router interface (RIF).
> 
> Until a new version that supports this functionality is made available,
> delete neighbours one by one.
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied.
