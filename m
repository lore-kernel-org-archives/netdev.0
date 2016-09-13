From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/5] mlxsw: ethtool enhancements
Date: Tue, 13 Sep 2016 12:17:36 -0400 (EDT)
Message-ID: <20160913.121736.1143024299087434838.davem@davemloft.net>
References: <1473679587-9112-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40770 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753312AbcIMQRk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 12:17:40 -0400
In-Reply-To: <1473679587-9112-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 12 Sep 2016 13:26:22 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Ido says:
> 
> Patches 1-4 do some minor cleanup in current ethtool ops. Patch 5
> replace legacy {get,set}_settings callbacks with
> {get,set}_link_ksettings.

Series applied, thanks guys.
