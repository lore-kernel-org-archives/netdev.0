From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net-next): ipsec-next 2017-06-23
Date: Fri, 23 Jun 2017 14:18:19 -0400 (EDT)
Message-ID: <20170623.141819.1988940567947681365.davem@davemloft.net>
References: <1498207110-22520-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35090 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754718AbdFWSSV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 14:18:21 -0400
In-Reply-To: <1498207110-22520-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Fri, 23 Jun 2017 10:38:24 +0200

> 1) Use memdup_user to spmlify xfrm_user_policy.
>    From Geliang Tang.
> 
> 2) Make xfrm_dev_register static to silence a sparse warning.
>    From Wei Yongjun.
> 
> 3) Use crypto_memneq to check the ICV in the AH protocol.
>    From Sabrina Dubroca.
> 
> 4) Remove some unused variables in esp6.
>    From Stephen Hemminger.
> 
> 5) Extend XFRM MIGRATE to allow to change the UDP encapsulation port.
>    From Antony Antony.
> 
> 6) Include the UDP encapsulation port to km_migrate announcements.
>    From Antony Antony.
> 
> Please pull or let me know if there are problems.

Pulled, thank you very much.
