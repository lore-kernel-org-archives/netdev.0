From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Fix qstats.qlen updating in dump_stats
Date: Thu, 17 Sep 2009 10:26:14 -0700 (PDT)
Message-ID: <20090917.102614.60596483.davem@davemloft.net>
References: <20090916103838.GA9719@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35535
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754830AbZIQRZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2009 13:25:57 -0400
In-Reply-To: <20090916103838.GA9719@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 16 Sep 2009 10:38:38 +0000

> Some classful qdiscs miss qstats.qlen updating with q.qlen of their
> child qdiscs in dump_stats methods.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied, thanks.
