From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 3/3] enic: Always use single transmit and
 single receive hardware queues per device
Date: Thu, 17 Feb 2011 14:12:35 -0800 (PST)
Message-ID: <20110217.141235.48514315.davem@davemloft.net>
References: <20110217185245.2476.60944.stgit@savbu-pc100.cisco.com>
	<20110217185322.2476.10728.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vkolluri@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45848
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753939Ab1BQWL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 17:11:59 -0500
In-Reply-To: <20110217185322.2476.10728.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>
Date: Thu, 17 Feb 2011 10:53:22 -0800

> From: Vasanthy Kolluri <vkolluri@cisco.com>
> 
> 
> 
> Signed-off-by: Christian Benvenuti <benve@cisco.com>
> Signed-off-by: Danny Guo <dannguo@cisco.com>
> Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
> Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
> Signed-off-by: David Wang <dwang2@cisco.com>

You can't make a very serious change like this with such a terse commit
message, you have to explain exactly why this change is being made.
