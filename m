From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC]: napi_struct V6
Date: Wed, 08 Aug 2007 16:18:04 -0700 (PDT)
Message-ID: <20070808.161804.102908198.davem@davemloft.net>
References: <20070807.215432.09951753.davem@davemloft.net>
	<20070808070628.284d805c@oldman>
	<46B9EEF7.7060009@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	hadi@cyberus.ca, rusty@rustcorp.com.au
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37315
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1763029AbXHHXSH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 19:18:07 -0400
In-Reply-To: <46B9EEF7.7060009@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Wed, 08 Aug 2007 12:27:35 -0400

> Someone please make sure Documentation/networking/netdevices.txt remains 
> correct with regards to APIs and locking.
> 
> It -is- up to date, unlike NAPI howto.  It should not change very much 
> due to this napi_struct work though, if at all.

I'll take care of it when I cut my net-2.6.24 tree later today.
