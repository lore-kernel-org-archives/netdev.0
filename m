From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 1/3][ROUTE] Collect proc-related functions
 together
Date: Wed, 05 Dec 2007 21:13:56 -0800 (PST)
Message-ID: <20071205.211356.150073064.davem@davemloft.net>
References: <4756DA10.6000409@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45926
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750945AbXLFFN4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 00:13:56 -0500
In-Reply-To: <4756DA10.6000409@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 05 Dec 2007 20:04:16 +0300

> The net/ipv4/route.c file declares some entries for proc
> to dump some routing info. The reading functions are 
> scattered over this file - collect them together.
> 
> Besides, remove a useless IP_RT_ACCT_CPU macro.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
