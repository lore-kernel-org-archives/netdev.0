From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NET_SCHED] sch_prio: class statistics printing enabled
Date: Wed, 31 Jan 2007 12:21:38 -0800 (PST)
Message-ID: <20070131.122138.106266328.davem@davemloft.net>
References: <45C0A9A5.4080607@trash.net>
	<20070131152245.GB3811@ff.dom.local>
	<45C0B485.5070307@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@o2.pl, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40286
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161018AbXAaUVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jan 2007 15:21:39 -0500
In-Reply-To: <45C0B485.5070307@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 31 Jan 2007 16:23:49 +0100

> Jarek Poplawski wrote:
> > This patch adds a dump_stats callback to enable
> > printing of basic statistics of prio classes.
> > (With help of Patrick McHardy).
> > 
> > Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>
> 
> Acked-by: Patrick McHardy <kaber@trash.net>

Applied to net-2.6.21, thanks.
