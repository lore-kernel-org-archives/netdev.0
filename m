From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] mlxsw: spectrum_dpipe: Fix sparse warnings
Date: Thu, 18 May 2017 11:06:08 -0400 (EDT)
Message-ID: <20170518.110608.26432535069555540.davem@davemloft.net>
References: <20170518072245.12494-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44030 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932643AbdERPGK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 11:06:10 -0400
In-Reply-To: <20170518072245.12494-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 18 May 2017 09:22:45 +0200

> From: Arkadi Sharshevsky <arkadis@mellanox.com>
> 
> drivers/net/ethernet/mellanox/mlxsw//spectrum_dpipe.c:221:52: warning:
> Using plain integer as NULL pointer
> drivers/net/ethernet/mellanox/mlxsw//spectrum_dpipe.c:221:74: warning:
> Using plain integer as NULL pointer
> 
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied.
