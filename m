From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/7] net: Plumb extack error reporting to
 enslavements
Date: Wed, 04 Oct 2017 21:42:17 -0700 (PDT)
Message-ID: <20171004.214217.633098016702209791.davem@davemloft.net>
References: <1507164531-17732-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
        andy@greyhouse.net, jiri@mellanox.com, idosch@mellanox.com,
        bridge@lists.linux-foundation.org
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60770 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750761AbdJEEmS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 00:42:18 -0400
In-Reply-To: <1507164531-17732-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Wed,  4 Oct 2017 17:48:44 -0700

> Another round of extending extack error reporting, this time for
> enslavements through ndo_add_slave and notifiers.
> 
> v2
> - changed how the messages are added to bonding driver per Jiri's request
> - fixed spectrum message for LAG overflow per Ido's comment

Series applied, thanks David.
