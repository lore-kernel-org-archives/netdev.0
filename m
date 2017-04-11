From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net-next): ipsec-next 2017-04-11
Date: Tue, 11 Apr 2017 10:32:37 -0400 (EDT)
Message-ID: <20170411.103237.1663193174723128796.davem@davemloft.net>
References: <1491890032-28655-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59756 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753554AbdDKOcr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 10:32:47 -0400
In-Reply-To: <1491890032-28655-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 11 Apr 2017 07:53:48 +0200

> 1) Remove unused field from struct xfrm_mgr.
> 
> 2) Code size optimizations for the xfrm prefix hash and
>    address match.
> 
> 3) Branch optimization for addr4_match.
> 
> All patches from Alexey Dobriyan.
> 
> Please pull or let me know if there are problems.

Pulled, thanks Steffen.
