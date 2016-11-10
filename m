From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] bnxt_en: do not call napi_hash_add()
Date: Wed, 09 Nov 2016 21:16:38 -0500 (EST)
Message-ID: <20161109.211638.782755991454410093.davem@davemloft.net>
References: <1478632013.17367.23.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michael.chan@broadcom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47586 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755038AbcKJCQk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 21:16:40 -0500
In-Reply-To: <1478632013.17367.23.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 08 Nov 2016 11:06:53 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> This is automatically done from netif_napi_add(), and we want to not
> export napi_hash_add() anymore in the following patch.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
