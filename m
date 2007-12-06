From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IPv4] Reply net unreachable ICMP message
Date: Wed, 05 Dec 2007 22:33:44 -0800 (PST)
Message-ID: <20071205.223344.156367240.davem@davemloft.net>
References: <20071206153105.df7d112f.mitch@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mitch@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54749
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752680AbXLFGdr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 01:33:47 -0500
In-Reply-To: <20071206153105.df7d112f.mitch@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Date: Thu, 6 Dec 2007 15:31:05 +0900

> IPv4 stack doesn't reply any ICMP destination unreachable message
> with net unreachable code when IP detagrams are being discarded
> because of no route could be found in the forwarding path.
> Incidentally, IPv6 stack replies such ICMPv6 message in the similar
> situation.
> 
> Signed-off-by: Mitsuru Chinen <mitch@linux.vnet.ibm.com>

Also applied, thank you.
