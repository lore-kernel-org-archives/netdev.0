From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] econet: have failed ec_queue_packet() call return
 NET_RX_BAD
Date: Sun, 05 Jul 2009 19:47:05 -0700 (PDT)
Message-ID: <20090705.194705.179239113.davem@davemloft.net>
References: <20090620200438.b5443520.lk-netdev@lk-netdev.nosense.org>
	<20090620105325.GC31266@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lk-netdev@lk-netdev.nosense.org, netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36963
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756223AbZGFCq6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2009 22:46:58 -0400
In-Reply-To: <20090620105325.GC31266@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Sat, 20 Jun 2009 12:53:25 +0200

> Subject: [PATCH] net: remove NET_RX_BAD and NET_RX_CN* defines
> 
> almost no users in the tree; and the few that use them treat them
> like NET_RX_DROP.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied to net-next-2.6
