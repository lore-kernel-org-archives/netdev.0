From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: sr: select DST_CACHE by default
Date: Mon, 27 Mar 2017 16:05:25 -0700 (PDT)
Message-ID: <20170327.160525.1511097640312727698.davem@davemloft.net>
References: <20170327094359.28595-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david.lebrun@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52872 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752469AbdC0XFv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 19:05:51 -0400
In-Reply-To: <20170327094359.28595-1-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lebrun <david.lebrun@uclouvain.be>
Date: Mon, 27 Mar 2017 11:43:59 +0200

> When CONFIG_IPV6_SEG6_LWTUNNEL is selected, automatically select DST_CACHE.
> This allows to remove multiple ifdefs.
> 
> Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>

Applied, thanks for following up on this David.
