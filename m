From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: introduce NLA_BINARY type
Date: Fri, 23 Mar 2007 11:38:08 -0700 (PDT)
Message-ID: <20070323.113808.112622864.davem@davemloft.net>
References: <1174662125.3366.34.camel@johannes.berg>
	<20070323151324.GD521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37827
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753280AbXCWSiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 14:38:09 -0400
In-Reply-To: <20070323151324.GD521@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Fri, 23 Mar 2007 16:13:24 +0100

> * Johannes Berg <johannes@sipsolutions.net> 2007-03-23 16:02
> > This patch introduces a new NLA_BINARY attribute policy type with the
> > verification of simply checking the maximum length of the payload.
> > 
> > It also fixes a small typo in the example.
> > 
> > Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
> > Cc: Thomas Graf <tgraf@suug.ch>
> > Cc: netdev@vger.kernel.org
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied to net-2.6.22, thanks everyone.
