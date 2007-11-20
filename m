From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/11] netpoll: no need to store local_mac
Date: Mon, 19 Nov 2007 19:23:45 -0800 (PST)
Message-ID: <20071119.192345.103966665.davem@davemloft.net>
References: <20071103184314.216145305@linux-foundation.org>
	<20071103184338.581312051@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: satyam@infradead.org, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53365
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754143AbXKTDXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 22:23:46 -0500
In-Reply-To: <20071103184338.581312051@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Sat, 03 Nov 2007 11:43:17 -0700

> The local_mac is managed by the network device, no need to
> keep a spare copy and all the management problems that could
> cause.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied to net-2.6.25, thanks!
