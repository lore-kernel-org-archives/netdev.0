From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net): ipsec 2017-04-28
Date: Fri, 28 Apr 2017 15:42:26 -0400 (EDT)
Message-ID: <20170428.154226.1750030287665309093.davem@davemloft.net>
References: <1493370873-30836-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58316 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1426623AbdD1Tm2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 15:42:28 -0400
In-Reply-To: <1493370873-30836-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Fri, 28 Apr 2017 11:14:31 +0200

> 1) Do garbage collecting after a policy flush to remove old
>    bundles immediately. From Xin Long.
> 
> 2) Fix GRO if netfilter is not defined.
>    From Sabrina Dubroca.
> 
> Please pull or let me know if there are problems.

Pulled, thanks!
