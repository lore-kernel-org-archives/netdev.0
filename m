From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/3] enic: Bug fix: Reset driver count of
 registered unicast addresses to zero during device reset
Date: Thu, 17 Feb 2011 14:14:17 -0800 (PST)
Message-ID: <20110217.141417.260095391.davem@davemloft.net>
References: <20110217185245.2476.60944.stgit@savbu-pc100.cisco.com>
	<20110217185311.2476.27883.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vkolluri@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35102
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754879Ab1BQWNl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 17:13:41 -0500
In-Reply-To: <20110217185311.2476.27883.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>
Date: Thu, 17 Feb 2011 10:53:12 -0800

> From: Vasanthy Kolluri <vkolluri@cisco.com>
> 
> During a device reset, clear the counter for the no. of unicast addresses registered.
> Also, rename the routines that update unicast and multicast address lists.
> 
> Signed-off-by: Christian Benvenuti <benve@cisco.com>
> Signed-off-by: Danny Guo <dannguo@cisco.com>
> Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
> Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
> Signed-off-by: David Wang <dwang2@cisco.com>

Applied.
