From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: use an RB tree for ooo receive queue
Date: Thu, 08 Sep 2016 17:26:49 -0700 (PDT)
Message-ID: <20160908.172649.1341473320811443941.davem@davemloft.net>
References: <1473284968.15733.8.camel@edumazet-glaptop3.roam.corp.google.com>
        <alpine.DEB.2.10.1609081236470.18111@whp-28.cs.helsinki.fi>
        <24063985-7837-ca69-6da0-6522dd1e9dbb@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: ilpo.jarvinen@helsinki.fi, eric.dumazet@gmail.com,
        netdev@vger.kernel.org, wygivan@google.com, ycheng@google.com,
        ncardwell@google.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42956 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750832AbcIIA1K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 20:27:10 -0400
In-Reply-To: <24063985-7837-ca69-6da0-6522dd1e9dbb@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu, 8 Sep 2016 16:31:22 +0200

> Le 08/09/2016 à 13:02, Ilpo Järvinen a écrit :
> [snip]
>> Acked-By: Ilpo Järvinen <ilpo.jarvinen@helsinki>
> Also nitpicking: the end of the email address is missing ;-)

I fixed this up when I applied the patch.
