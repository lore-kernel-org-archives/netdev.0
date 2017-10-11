From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] macsec: fix memory leaks when skb_to_sgvec fails
Date: Wed, 11 Oct 2017 14:07:50 -0700 (PDT)
Message-ID: <20171011.140750.376971409050495916.davem@davemloft.net>
References: <5d21bccd731e3c54f2216fcf3b12cd40ba708f7b.1507639962.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jason@zx2c4.com
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36712 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751981AbdJKVHv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 17:07:51 -0400
In-Reply-To: <5d21bccd731e3c54f2216fcf3b12cd40ba708f7b.1507639962.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Tue, 10 Oct 2017 17:07:12 +0200

> Fixes: cda7ea690350 ("macsec: check return value of skb_to_sgvec always")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Applied and queued up for -stable.
