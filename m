From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next RESEND 1/1] driver: ipvlan: Define common
 functions to decrease duplicated codes used to add or del IP address
Date: Wed, 28 Dec 2016 14:24:37 -0500 (EST)
Message-ID: <20161228.142437.236650966364866731.davem@davemloft.net>
References: <1482914811-2700-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maheshb@google.com, edumazet@google.com, netdev@vger.kernel.org,
        gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44082 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751890AbcL1TYk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 14:24:40 -0500
In-Reply-To: <1482914811-2700-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fgao@ikuai8.com
Date: Wed, 28 Dec 2016 16:46:51 +0800

> From: Gao Feng <fgao@ikuai8.com>
> 
> There are some duplicated codes in ipvlan_add_addr6/4 and
> ipvlan_del_addr6/4. Now define two common functions ipvlan_add_addr
> and ipvlan_del_addr to decrease the duplicated codes.
> It could be helful to maintain the codes.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>

Applied.
