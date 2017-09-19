From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 00/13] mlxsw: Prepare for multicast router
 offload
Date: Tue, 19 Sep 2017 14:24:54 -0700 (PDT)
Message-ID: <20170919.142454.1178970746129060723.davem@davemloft.net>
References: <20170919080020.5870-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45896 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751309AbdISVYz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 17:24:55 -0400
In-Reply-To: <20170919080020.5870-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 19 Sep 2017 10:00:07 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Yotam says:
> 
> This patch-set makes various preparations needed for the multicast router
> offloading, which include:
>  - Add the needed registers.
>  - Add needed ACL actions.
>  - Add new traps and trap groups.
>  - Exporting needed private structs and enums.

Series applied, thank you.
