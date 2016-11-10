From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] net: napi_hash_add() is no longer exported
Date: Wed, 09 Nov 2016 21:16:43 -0500 (EST)
Message-ID: <20161109.211643.311663169383399960.davem@davemloft.net>
References: <1478632048.17367.24.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michael.chan@broadcom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47594 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755038AbcKJCQq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 21:16:46 -0500
In-Reply-To: <1478632048.17367.24.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 08 Nov 2016 11:07:28 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> There are no more users except from net/core/dev.c
> napi_hash_add() can now be static.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
