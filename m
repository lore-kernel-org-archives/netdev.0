From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next v4 0/3] net: allow setting ecn via routing table
Date: Tue, 04 Nov 2014 16:14:37 -0500 (EST)
Message-ID: <20141104.161437.2022044824377367603.davem@davemloft.net>
References: <1415032503-4936-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59443 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751241AbaKDVOn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 16:14:43 -0500
In-Reply-To: <1415032503-4936-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon,  3 Nov 2014 17:35:00 +0100

> Here is v4 of the patchset, its exactly the same as v3 except in patch3/3
> where I added the missing 'const' qualifier to a function argument that
> Eric spotted during review.
> 
> I preserved Erics Acks so that he doesn't have to resend them.

Looks great, series applied, thanks Florian.

I particularly like how the syncookie code was handled.
