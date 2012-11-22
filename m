From: David Miller <davem@davemloft.net>
Subject: Re: pull request: ipsec-next 2012-11-22
Date: Thu, 22 Nov 2012 15:26:52 -0500 (EST)
Message-ID: <20121122.152652.116392794025807756.davem@davemloft.net>
References: <1353571362-6774-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36550 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756863Ab2KVU0y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2012 15:26:54 -0500
In-Reply-To: <1353571362-6774-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 22 Nov 2012 09:02:38 +0100

> This pull request is intended for net-next and contains the following changes:
> 
> 1) Remove a redundant check when initializing the xfrm replay functions,
>    from Ulrich Weber.
> 2) Use a faster per-cpu helper when allocating ipcomt transforms,
>    from Shan Wei.
> 3) Use a static gc threshold value for ipv6, simmilar to what we do
>    for ipv4 now.
> 4) Remove a commented out function call.
> 
> Please pull or let me know if there are problems.

Also pulled, thanks.
