From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] use stack instead of heap
Date: Wed, 06 Feb 2013 15:56:43 -0500 (EST)
Message-ID: <20130206.155643.191335977410378423.davem@davemloft.net>
References: <1360095824-12538-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: alex.aring@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43658 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756778Ab3BFU4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 15:56:45 -0500
In-Reply-To: <1360095824-12538-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Aring <alex.aring@gmail.com>
Date: Tue,  5 Feb 2013 21:23:42 +0100

> In 6lowpan and mac802154 implemenation is a allocated
> temp heap buffer, which can also on the stack.
> 
> I hope 100 bytes in 6lowpan are fine.

Series applied to net-next, thanks.
