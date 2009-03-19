From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tipc: fix non-const printf format arguments
Date: Wed, 18 Mar 2009 19:11:41 -0700 (PDT)
Message-ID: <20090318.191141.262845346.davem@davemloft.net>
References: <20090317112832.66832ce4@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: per.linden@ericsson.com, jon.maloy@ericsson.com,
	allan.stephens@windriver.com,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55802
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751383AbZCSCLz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 22:11:55 -0400
In-Reply-To: <20090317112832.66832ce4@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 17 Mar 2009 11:28:32 -0700

> Fix warnings from current gcc about using non-const strings as printf args
> in TIPC. Compile tested only (not a TIPC user).
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied to net-next-2.6, thanks.
