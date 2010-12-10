From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] enic: Bug Fix: Pass napi reference to the isr
 that services receive queue
Date: Fri, 10 Dec 2010 15:01:24 -0800 (PST)
Message-ID: <20101210.150124.91342713.davem@davemloft.net>
References: <20101208230545.24082.48614.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roprabhu@cisco.com, dwang2@cisco.com
To: vkolluri@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45079
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752067Ab0LJXA4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 18:00:56 -0500
In-Reply-To: <20101208230545.24082.48614.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>
Date: Wed, 08 Dec 2010 15:05:45 -0800

> From: Vasanthy Kolluri <vkolluri@cisco.com>
> 
> Pass reference to napi instead of enic device to the isr that services receive queue.
> 
> Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
> Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
> Signed-off-by: David Wang <dwang2@cisco.com>

Applied, thank you.
