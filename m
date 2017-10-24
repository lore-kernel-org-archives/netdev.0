From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] mlxsw: spectrum_dpipe: Fix entries dump of
 the adjacency table
Date: Tue, 24 Oct 2017 19:02:20 +0900 (KST)
Message-ID: <20171024.190220.718981304472651931.davem@davemloft.net>
References: <20171024081142.996-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58526 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752104AbdJXKCZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 06:02:25 -0400
In-Reply-To: <20171024081142.996-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 24 Oct 2017 10:11:42 +0200

> From: Arkadi Sharshevsky <arkadis@mellanox.com>
> 
> During the dump the per netlink packet entry counter should be zeroed out
> when new packet is created.
> 
> Fixes: 190d38a52a73 ("mlxsw: spectrum_dpipe: Add support for adjacency table dump")
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
> Reported-by: David Ahern <dsahern@gmail.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied.
