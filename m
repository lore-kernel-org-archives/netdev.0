From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net): ipsec 2016-09-21
Date: Thu, 22 Sep 2016 02:56:42 -0400 (EDT)
Message-ID: <20160922.025642.1240231966190790980.davem@davemloft.net>
References: <1474455946-674-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55606 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750858AbcIVG4o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 02:56:44 -0400
In-Reply-To: <1474455946-674-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Wed, 21 Sep 2016 13:05:42 +0200

> 1) Propagate errors on security context allocation.
>    From Mathias Krause.
> 
> 2) Fix inbound policy checks for inter address family tunnels.
>    From Thomas Zeitlhofer.
> 
> 3) Fix an old memory leak on aead algorithm usage.
>    From Ilan Tayari.
> 
> 4) A recent patch fixed a possible NULL pointer dereference
>    but broke the vti6 input path.
>    Fix from Nicolas Dichtel.
> 
> Please pull or let me know if there are problems.

Pulled, thanks a lot Steffen.
