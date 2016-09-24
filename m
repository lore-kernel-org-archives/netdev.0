From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net-next): ipsec-next 2016-09-23
Date: Sat, 24 Sep 2016 08:19:17 -0400 (EDT)
Message-ID: <20160924.081917.1471603832129054329.davem@davemloft.net>
References: <1474614882-25253-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36782 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752656AbcIXMTU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 24 Sep 2016 08:19:20 -0400
In-Reply-To: <1474614882-25253-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Fri, 23 Sep 2016 09:14:40 +0200

> Only two patches this time:
> 
> 1) Fix a comment reference to struct xfrm_replay_state_esn.
>    From Richard Guy Briggs.
> 
> 2) Convert xfrm_state_lookup to rcu, we don't need the
>    xfrm_state_lock anymore in the input path.
>    From Florian Westphal.
> 
> Please pull or let me know if there are problems.

Pulled, thanks Steffen.
