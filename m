From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/4] ipv4: various pmtu discovery fixes
Date: Tue, 11 Oct 2011 15:54:51 -0400 (EDT)
Message-ID: <20111011.155451.870811156460684722.davem@davemloft.net>
References: <20111011110842.GC1830@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59986 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932065Ab1JKTzB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2011 15:55:01 -0400
In-Reply-To: <20111011110842.GC1830@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 11 Oct 2011 13:08:42 +0200

> This patchset addresses some issues I found during investigating
> pmtu discovery. These issues were introduced with
> git commit 2c8cec5 (ipv4: Cache learned PMTU information in inetpeer).
> 
> The patchset is based on current net/master.

Thanks a lot for these bug fixes, Herbert Xu reported similar issues.

I'll review these patches tonight.
