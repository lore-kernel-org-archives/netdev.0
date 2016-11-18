From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] rtnetlink: fix FDB size computation
Date: Fri, 18 Nov 2016 14:10:59 -0500 (EST)
Message-ID: <20161118.141059.1545399735812585925.davem@davemloft.net>
References: <9bef2a8afa6f8193fcca61ea381b67a52ab878b2.1479477903.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hubert.sokolowski@intel.com
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39712 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752057AbcKRTLB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 14:11:01 -0500
In-Reply-To: <9bef2a8afa6f8193fcca61ea381b67a52ab878b2.1479477903.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Fri, 18 Nov 2016 15:50:39 +0100

> Add missing NDA_VLAN attribute's size.
> 
> Fixes: 1e53d5bb8878 ("net: Pass VLAN ID to rtnl_fdb_notify.")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Applied and queued up for -stable, thanks.
