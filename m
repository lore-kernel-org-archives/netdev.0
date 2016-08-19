From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [patch net] mlxsw: spectrum_buffers: Fix pool value handling in
 mlxsw_sp_sb_tc_pool_bind_set
Date: Fri, 19 Aug 2016 16:03:55 +0300
Message-ID: <20160819130355.GA3185@splinter>
References: <1471610628-4287-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, nogahf@mellanox.com,
        ogerlitz@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:36891 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754635AbcHSND7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 09:03:59 -0400
Content-Disposition: inline
In-Reply-To: <1471610628-4287-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 19, 2016 at 02:43:48PM +0200, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> Pool index has to be converted by get_pool helper to work correctly for
> egress pool. In mlxsw the egress pool index starts from 0.
> 
> Fixes: 0f433fa0ecc ("mlxsw: spectrum_buffers: Implement shared buffer configuration")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Reviewed-by: Ido Schimmel <idosch@mellanox.com>

Thanks!
