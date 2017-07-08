From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] doc: SKB_GSO_[IPIP|SIT] have been replaced
Date: Sat, 08 Jul 2017 11:26:11 +0100 (WEST)
Message-ID: <20170708.112611.2177073366790102572.davem@davemloft.net>
References: <20170707120825.9691-1-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41210 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752555AbdGHK0P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Jul 2017 06:26:15 -0400
In-Reply-To: <20170707120825.9691-1-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri,  7 Jul 2017 14:08:25 +0200

> Those enum values don't exist anymore.
> 
> Fixes: 7e13318daa4a ("net: define gso types for IPx over IPv4 and IPv6")
> CC: Tom Herbert <tom@herbertland.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied, thanks.
