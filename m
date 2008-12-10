From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/6] pkt_sched: sch_htb: Consider used jiffies in
 htb_dequeue()
Date: Tue, 09 Dec 2008 22:35:45 -0800 (PST)
Message-ID: <20081209.223545.196224587.davem@davemloft.net>
References: <20081209130803.GB15353@ff.dom.local>
	<493E7080.5060308@trash.net>
	<20081209144534.GC15353@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, devik@cdi.cz, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37110
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755688AbYLJGfo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 01:35:44 -0500
In-Reply-To: <20081209144534.GC15353@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 9 Dec 2008 14:45:34 +0000

> To David Miller: David don't apply yet - this patch needs change.

What I've done is apply patches 5 and 6 since those are
fine and independent of these timer issues.

So once you work this stuff out please resubmit the rest.

Thanks!
