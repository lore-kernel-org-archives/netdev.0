From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] econet: have failed ec_queue_packet() call return
 NET_RX_BAD
Date: Mon, 06 Jul 2009 11:48:52 -0700 (PDT)
Message-ID: <20090706.114852.196263142.davem@davemloft.net>
References: <20090620105325.GC31266@Chamillionaire.breakpoint.cc>
	<20090705.194705.179239113.davem@davemloft.net>
	<20090706200214.7767fd6a.lk-netdev@lk-netdev.nosense.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org
To: lk-netdev@lk-netdev.nosense.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45704
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753922AbZGFSsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 14:48:45 -0400
In-Reply-To: <20090706200214.7767fd6a.lk-netdev@lk-netdev.nosense.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Date: Mon, 6 Jul 2009 20:02:14 +0930

> Will my first econet patch go in? It was just a "no magic numbers"
> patch, unrelated to the NET_RX_DROP vs NET_RX_BAD issue.

I'm happy to apply that one, could you please resend it
to the list?  That would make my life easier, thanks!
