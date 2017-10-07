From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] batman-adv: Add missing kerneldoc for extack
Date: Sat, 07 Oct 2017 20:59:52 +0100 (WEST)
Message-ID: <20171007.205952.775593212999479324.davem@davemloft.net>
References: <20171007121853.6278-1-sven@narfation.org>
        <20171007122122.6470-1-sven@narfation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
        dsahern@gmail.com
To: sven@narfation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41518 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752944AbdJGU2N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Oct 2017 16:28:13 -0400
In-Reply-To: <20171007122122.6470-1-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>
Date: Sat,  7 Oct 2017 14:21:22 +0200

> The parameter extack was added to batadv_softif_slave_add without adding
> the kernel-doc for it. This caused kernel-doc warnings.
> 
> Signed-off-by: Sven Eckelmann <sven@narfation.org>
> Cc: David Ahern <dsahern@gmail.com>

I'm happy to apply this but where are the other two patches of this
series and the series header posting?
