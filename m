From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] mlxsw: spectrum_switchdev: Fix mrouter flag update
Date: Tue, 22 Aug 2017 14:23:41 -0700 (PDT)
Message-ID: <20170822.142341.1959517682433811449.davem@davemloft.net>
References: <20170822082811.1356-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nogahf@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44192 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751853AbdHVVXm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 17:23:42 -0400
In-Reply-To: <20170822082811.1356-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 22 Aug 2017 10:28:11 +0200

> From: Nogah Frankel <nogahf@mellanox.com>
> 
> Update the value of the mrouter flag in struct mlxsw_sp_bridge_port when
> it is being changed.
> 
> Fixes: c57529e1d5d8 ("mlxsw: spectrum: Replace vPorts with Port-VLAN")
> Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied.
