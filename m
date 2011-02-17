From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 3/3] enic: Always use single transmit and
 single receive hardware queues per device
Date: Thu, 17 Feb 2011 14:48:21 -0800 (PST)
Message-ID: <20110217.144821.70213322.davem@davemloft.net>
References: <20110217185322.2476.10728.stgit@savbu-pc100.cisco.com>
	<20110217.141235.48514315.davem@davemloft.net>
	<212AA327A3557741A058E787E06188730564B99A@xmb-sjc-219.amer.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vkolluri@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42616
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751373Ab1BQWrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 17:47:45 -0500
In-Reply-To: <212AA327A3557741A058E787E06188730564B99A@xmb-sjc-219.amer.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vasanthy Kolluri (vkolluri)" <vkolluri@cisco.com>
Date: Thu, 17 Feb 2011 14:45:56 -0800

> Sorry for the short description.
> 
> We believe that our earlier patch for supporting multiple hardware
> receive queues per enic device requires more internal testing. At this
> point, we think that it's best to disable the use of multiple receive
> queues. We believe that the current patch will provide an effective
> means for the same.

Well then, resubmit your patch with an appropriate commit message.
