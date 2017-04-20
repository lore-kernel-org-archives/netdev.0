From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net): ipsec 2017-04-19
Date: Thu, 20 Apr 2017 16:20:17 -0400 (EDT)
Message-ID: <20170420.162017.1677591279608729707.davem@davemloft.net>
References: <1492578636-621-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48994 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1033541AbdDTUUT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 16:20:19 -0400
In-Reply-To: <1492578636-621-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Wed, 19 Apr 2017 07:10:34 +0200

> Two fixes for af_key:
> 
> 1) Add a lock to key dump to prevent a NULL pointer dereference.
>    From Yuejie Shi.
> 
> 2) Fix slab-out-of-bounds in parse_ipsecrequests.
>    From Herbert Xu.
> 
> Please pull or let me know if there are problems.

Pulled, thanks Steffen.
