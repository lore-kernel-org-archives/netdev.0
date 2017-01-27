From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3 0/3] various gtp fixes
Date: Fri, 27 Jan 2017 10:40:12 -0500 (EST)
Message-ID: <20170127.104012.823264164422411860.davem@davemloft.net>
References: <20170127094058.7899-1-aschultz@tpip.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netdev@vger.kernel.org,
        Lionel.Gauthier@eurecom.fr, openbsc@lists.osmocom.org,
        laforge@gnumonks.org, elfring@users.sourceforge.net
To: aschultz@tpip.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36694 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932733AbdA0Plr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 10:41:47 -0500
In-Reply-To: <20170127094058.7899-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Schultz <aschultz@tpip.net>
Date: Fri, 27 Jan 2017 10:40:55 +0100

> I'm sorry for the compile error mess up in the last version.
> It's no excuse for not test compiling, but the hunks got lost in
> a rebase.
> 
> This is the part of the previous "simple gtp improvements" series
> that Pablo indicated should go into net.
> 
> The addition of the module alias fixes genl family autoloading,
> clearing the DF bit fixes a protocol violation in regard to the
> specification and the netns comparison fixes a corner case of
> cross netns recv.
> 
> Andreas
> 
> v2->v3: fix compiler error introduced in rebase

Looks better, series applied, thanks.
