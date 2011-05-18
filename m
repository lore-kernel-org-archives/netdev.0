From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] sfc: Replace enum efx_fc_type with a
 'bitwise' type
Date: Tue, 17 May 2011 22:23:02 -0400 (EDT)
Message-ID: <20110517.222302.158419141035335293.davem@davemloft.net>
References: <1305666379.2848.45.camel@bwh-desktop>
	<20110517.171412.1017451005914294196.davem@davemloft.net>
	<4DD3285D.6010506@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43954 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750955Ab1ERCXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 22:23:30 -0400
In-Reply-To: <4DD3285D.6010506@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Tue, 17 May 2011 22:01:01 -0400

> On 05/17/2011 05:14 PM, David Miller wrote:
>> Accept that the compiler currently doesn't want to allow enums to be
>> used as bit-masks, don't paper around it.
> 
> This practice is all over the kernel.
> 
> It's a bit silly to make such a big deal, because of that.

"We do something stupid everywhere" is never a good
argument for anything.
