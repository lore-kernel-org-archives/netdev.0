From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next-2.6] netdev: tilepro: Use
 is_unicast_ether_addr helper
Date: Thu, 13 Jan 2011 21:51:58 -0800 (PST)
Message-ID: <20110113.215158.150157771.davem@davemloft.net>
References: <20110112.234250.10542369.davem@davemloft.net>
	<1294906508-14999-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cmetcalf@tilera.com, netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41231
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751939Ab1ANFv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 00:51:26 -0500
In-Reply-To: <1294906508-14999-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Thu, 13 Jan 2011 09:15:08 +0100

> Use is_unicast_ether_addr from linux/etherdevice.h instead of custom
> macros.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
