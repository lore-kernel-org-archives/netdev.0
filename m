From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] be2net: fix cmd-rx-filter not notifying MCC
Date: Wed, 03 Aug 2011 05:19:38 -0700 (PDT)
Message-ID: <20110803.051938.374945706783400461.davem@davemloft.net>
References: <1312371993-3015-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47313 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755459Ab1HCMTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2011 08:19:42 -0400
In-Reply-To: <1312371993-3015-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Wed, 3 Aug 2011 17:16:33 +0530

> Dave, I missed out on this line while composing the 4/6 patch from my
> yesterday's patchset ("[PATCH net-next 4/6] be2net: use RX_FILTER cmd to program multicast addresses"). As you've already queued up the patchset for net-next,
>  I'm sending the fix in a separate patch. Pls apply.
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Ok, applied, thanks.
