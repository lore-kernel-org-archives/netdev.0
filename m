From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 3/3][ARP] Consolidate some code in
 arp_req_set/delete_publc
Date: Wed, 05 Dec 2007 21:21:10 -0800 (PST)
Message-ID: <20071205.212110.199760435.davem@davemloft.net>
References: <4756DD74.4090304@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49729
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751262AbXLFFVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 00:21:10 -0500
In-Reply-To: <4756DD74.4090304@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 05 Dec 2007 20:18:44 +0300

> The PROXY_ARP is set on devconfigs in a similar way in
> both calls.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Also applied, thanks a lot.
