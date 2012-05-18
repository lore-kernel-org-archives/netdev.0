From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] iwlwifi: dont pull too much payload in skb
 head
Date: Fri, 18 May 2012 13:31:36 -0400 (EDT)
Message-ID: <20120518.133136.1737334367748084291.davem@davemloft.net>
References: <1337352513.7029.18.camel@edumazet-glaptop>
	<1DC40B07CD6EC041A66726C271A73AE61955AE5D@IRSMSX102.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	wey-yi.w.guy@intel.com
To: johannes.berg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43015 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754441Ab2ERRbl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2012 13:31:41 -0400
In-Reply-To: <1DC40B07CD6EC041A66726C271A73AE61955AE5D@IRSMSX102.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Berg, Johannes" <johannes.berg@intel.com>
Date: Fri, 18 May 2012 14:59:04 +0000

>> Since merge window is now pretty close, I would prefer David applies this
>> directly in net-next, if you dont mind, as this patch is more a core network issue
>> than an iwlwifi one.
>> 
>> Thanks !
> 
> Sure, good with me, I don't think we have colliding patches.
> 
> Reviewed-by: Johannes Berg <johannes.berg@intel.com>

Applied.
