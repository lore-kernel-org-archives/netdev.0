From: David Miller <davem@davemloft.net>
Subject: Re: [NETLINK]: Restore API compatibility of address and neighbour
 bits
Date: Thu, 07 Dec 2006 23:52:33 -0800 (PST)
Message-ID: <20061207.235233.112851978.davem@davemloft.net>
References: <20061207.025140.75779834.davem@davemloft.net>
	<20061207105502.GJ8693@postel.suug.ch>
	<1165490908.5253.275.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, stable@kernel.org, stefan@loplof.de,
	joseph@codesourcery.com, netdev@vger.kernel.org,
	libc-alpha@sourceware.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44884
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1425100AbWLHHwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Dec 2006 02:52:19 -0500
To: dwmw2@infradead.org
In-Reply-To: <1165490908.5253.275.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Woodhouse <dwmw2@infradead.org>
Date: Thu, 07 Dec 2006 11:28:28 +0000

> On Thu, 2006-12-07 at 11:55 +0100, Thomas Graf wrote:
> > Restore API compatibility due to bits moved from rtnetlink.h to
> > separate headers.
> 
> For 2.6.19.1 too, please.

I will, thanks for reminding me.
