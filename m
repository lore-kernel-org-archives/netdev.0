From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [patch net 1/2] mlxsw: spectrum_router: Fix error path in
 mlxsw_sp_router_init
Date: Thu, 8 Sep 2016 09:38:16 +0300
Message-ID: <20160908063816.GA7364@splinter>
References: <1473315362-1984-1-git-send-email-jiri@resnulli.us>
 <1473315362-1984-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, nogahf@mellanox.com,
        ogerlitz@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:60958 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752676AbcIHGiU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 02:38:20 -0400
Content-Disposition: inline
In-Reply-To: <1473315362-1984-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 08, 2016 at 08:16:01AM +0200, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> When neigh_init fails, we have to do proper cleanup including
> router_fini call.
> 
> Fixes: 6cf3c971dc84cb ("mlxsw: spectrum_router: Add private neigh table")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Acked-by: Ido Schimmel <idosch@mellanox.com>

Thanks
