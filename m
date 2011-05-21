From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] ipv6: copy prefsrc setting when copying route entry
Date: Sat, 21 May 2011 02:06:09 -0400 (EDT)
Message-ID: <20110521.020609.637818236638393620.davem@davemloft.net>
References: <1305926844-12995-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sahne@0x90.at
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57925 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808Ab1EUGGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 May 2011 02:06:23 -0400
In-Reply-To: <1305926844-12995-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Fri, 20 May 2011 23:27:24 +0200

> commit c3968a857a6b6c3d2ef4ead35776b055fb664d74
> ('ipv6: RTA_PREFSRC support for ipv6 route source address selection')
> added support for ipv6 prefsrc as an alternative to ipv6 addrlabels,
> but it did not work because the prefsrc entry was not copied.
> 
> Cc: Daniel Walter <sahne@0x90.at>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied.
