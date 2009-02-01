From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3 net-next] pkt_sched: sch_htb: Warn on too many
 events.
Date: Sun, 01 Feb 2009 01:13:41 -0800 (PST)
Message-ID: <20090201.011341.93031196.davem@davemloft.net>
References: <20090128125230.GA6282@ff.dom.local>
	<49808544.5010304@trash.net>
	<20090130101714.GB8882@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, devik@cdi.cz, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40656
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752184AbZBAJNo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Feb 2009 04:13:44 -0500
In-Reply-To: <20090130101714.GB8882@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Fri, 30 Jan 2009 10:17:15 +0000

> pkt_sched: sch_htb: Warn on too many events.
> 
> Let's get some info on possible config problems. This patch brings
> back an old warning, but is printed only once now.
> 
> With feedback from Patrick McHardy <kaber@trash.net>
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied.
