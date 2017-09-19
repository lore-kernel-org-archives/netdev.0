From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 08/14] gtp: Support encpasulating over IPv6
Date: Mon, 18 Sep 2017 21:19:52 -0700 (PDT)
Message-ID: <20170918.211952.1397675528248642600.davem@davemloft.net>
References: <20170919003904.5124-1-tom@quantonium.net>
        <20170919003904.5124-9-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pablo@netfilter.org, laforge@gnumonks.org,
        rohit@quantonium.net
To: tom@quantonium.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38610 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750774AbdISETw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 00:19:52 -0400
In-Reply-To: <20170919003904.5124-9-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@quantonium.net>
Date: Mon, 18 Sep 2017 17:38:58 -0700

> Allow peers to be specified by IPv6 addresses.
> 
> Signed-off-by: Tom Herbert <tom@quantonium.net>

Hmmm, can you just check the socket family or something like that?
