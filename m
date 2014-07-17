From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/7] tipc: multicast and internal users to
 new send functions
Date: Wed, 16 Jul 2014 21:38:47 -0700 (PDT)
Message-ID: <20140716.213847.454623349375421459.davem@davemloft.net>
References: <1405556318-14240-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57303 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740AbaGQEiv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 00:38:51 -0400
In-Reply-To: <1405556318-14240-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Wed, 16 Jul 2014 20:18:31 -0400

> We move the remaining data transmit users: multicast, name table
> distributor, and link internal protocols to use the new data
> transmission framework introduced in a previous commit series
> ("tipc: new unicast transmission code").
> 
> Finally, we remove the code obsoleted by the new functions.
> 
> v2: - Fixed a braindead, but harmless return sequence in commit #3, as
>       reported by David Miller.
>     - Rebased series to 3.16.0-rc5+

Series applied, thanks Jon.
