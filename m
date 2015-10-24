From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] amd-xgbe: Use wmb before updating current
 descriptor count
Date: Fri, 23 Oct 2015 17:43:48 -0700 (PDT)
Message-ID: <20151023.174348.469923046006238997.davem@davemloft.net>
References: <20151021203705.29412.11836.stgit@tlendack-t1.amdoffice.net>
	<562A6078.9070709@gmail.com>
	<562A66F7.8040908@amd.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com, netdev@vger.kernel.org,
	christoffer.dall@linaro.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39454 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750869AbbJXA1T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 20:27:19 -0400
In-Reply-To: <562A66F7.8040908@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Fri, 23 Oct 2015 11:57:27 -0500

> David, if this is indeed the proper fix would you want to me to send a
> new patch based on this old patch or a new patch based on you having
> reverted the old patch?

One never sends me a "new patch" for a patch I've already applied, once I
apply it, it is there forever and must either be fixed with a relative
patch or reverted.
