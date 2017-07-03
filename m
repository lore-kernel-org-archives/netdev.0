From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: make sk_ehashfn() static
Date: Mon, 03 Jul 2017 03:30:02 -0700 (PDT)
Message-ID: <20170703.033002.552292378637751144.davem@davemloft.net>
References: <1499075874.1462.6.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55484 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753018AbdGCKaF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2017 06:30:05 -0400
In-Reply-To: <1499075874.1462.6.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 03 Jul 2017 02:57:54 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> sk_ehashfn() is only used from a single file.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
