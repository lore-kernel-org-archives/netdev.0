From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4] be2net: Fix to allow get/set of debug
 levels in the firmware.
Date: Thu, 17 May 2012 22:45:37 -0400 (EDT)
Message-ID: <20120517.224537.1260021472621276535.davem@davemloft.net>
References: <23cb36ad-2827-44bd-a91a-c6d8b01db70e@exht1.ad.emulex.com>
	<20120517.162116.881586126577077171.davem@davemloft.net>
	<80fb6a42-aa9a-4288-aa96-c6aa5972bc03@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	Suresh.Reddy@Emulex.Com
To: Somnath.Kotur@Emulex.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37127 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751562Ab2ERCpn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 22:45:43 -0400
In-Reply-To: <80fb6a42-aa9a-4288-aa96-c6aa5972bc03@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Somnath.Kotur@Emulex.Com>
Date: Thu, 17 May 2012 18:47:50 -0700

> At the moment our driver does not have any extensive logging
> facility, but yes going forward we will use this infrastructure to
> gate all our driver's logging and will send separate patch(es) for
> that in future.
> 
> Does that sound good for now?  A respin for this current patch 

Yes.
