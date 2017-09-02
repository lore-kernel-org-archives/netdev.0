From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: systemport: Correctly set TSB endian for
 host
Date: Fri, 01 Sep 2017 20:19:43 -0700 (PDT)
Message-ID: <20170901.201943.461878148379473287.davem@davemloft.net>
References: <1504312354-62020-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57810 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750941AbdIBDUu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 23:20:50 -0400
In-Reply-To: <1504312354-62020-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri,  1 Sep 2017 17:32:34 -0700

> Similarly to how we configure the RSB (Receive Status Block) we also
> need to set the TSB (Transmit Status Block) based on the host endian.
> This was missing from the commit indicated below.
> 
> Fixes: 389a06bc534e ("net: systemport: Set correct RSB endian bits based on host")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks Florian.
