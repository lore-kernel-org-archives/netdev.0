From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] genetlink: Fix generic netlink family
 unregister
Date: Sat, 29 Oct 2016 20:58:54 -0400 (EDT)
Message-ID: <20161029.205854.2148929009505255718.davem@davemloft.net>
References: <1477695701-1147-1-git-send-email-pshelar@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johannes@sipsolutions.net
To: pshelar@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54688 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753425AbcJ3A67 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 20:58:59 -0400
In-Reply-To: <1477695701-1147-1-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@ovn.org>
Date: Fri, 28 Oct 2016 16:01:41 -0700

> This patch fixes a typo in unregister operation.
> 
> Following crash is fixed by this patch. It can be easily reproduced
> by repeating modprobe and rmmod module that uses genetlink.
 ...
> Fixes: 2ae0f17df1c ("genetlink: use idr to track families").
> 
> Reported-by: Jarno Rajahalme <jarno@ovn.org>
> CC: Johannes Berg <johannes@sipsolutions.net>
> Signed-off-by: Pravin B Shelar <pshelar@ovn.org>

Applied, thank you.
