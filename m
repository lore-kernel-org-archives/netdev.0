From: David Miller <davem@davemloft.net>
Subject: Re: [NETLINK]: Restore API compatibility of address and neighbour
 bits
Date: Thu, 07 Dec 2006 23:50:34 -0800 (PST)
Message-ID: <20061207.235034.95895574.davem@davemloft.net>
References: <20061207104721.GI8693@postel.suug.ch>
	<20061207.025140.75779834.davem@davemloft.net>
	<20061207105502.GJ8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stefan@loplof.de, dwmw2@infradead.org, joseph@codesourcery.com,
	netdev@vger.kernel.org, libc-alpha@sourceware.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44870
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1425097AbWLHHuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Dec 2006 02:50:20 -0500
To: tgraf@suug.ch
In-Reply-To: <20061207105502.GJ8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 7 Dec 2006 11:55:02 +0100

> Restore API compatibility due to bits moved from rtnetlink.h to
> separate headers.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks for taking care of this Thomas.
