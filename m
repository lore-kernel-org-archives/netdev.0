From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rhashtable: Documentation tweak
Date: Tue, 19 Sep 2017 15:19:05 -0700 (PDT)
Message-ID: <20170919.151905.496299042728728209.davem@davemloft.net>
References: <20170919104137.22916-1-agruenba@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: agruenba@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48218 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751361AbdISWTG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 18:19:06 -0400
In-Reply-To: <20170919104137.22916-1-agruenba@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Tue, 19 Sep 2017 12:41:37 +0200

> Clarify that rhashtable_walk_{stop,start} will not reset the iterator to
> the beginning of the hash table.  Confusion between rhashtable_walk_enter
> and rhashtable_walk_start has already lead to a bug.
> 
> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>

Applied, thanks.
