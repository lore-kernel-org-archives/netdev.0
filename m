From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Re: [PATCH] econet: have failed ec_queue_packet() call return
 NET_RX_BAD
Date: Tue, 7 Jul 2009 06:37:52 +0930
Message-ID: <20090707063752.8e4fc5cf.lk-netdev@lk-netdev.nosense.org>
References: <20090620105325.GC31266@Chamillionaire.breakpoint.cc>
	<20090705.194705.179239113.davem@davemloft.net>
	<20090706200214.7767fd6a.lk-netdev@lk-netdev.nosense.org>
	<20090706.114852.196263142.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.adam.net.au ([202.136.110.249]:58733 "EHLO
	smtp3.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751651AbZGFVHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 17:07:55 -0400
In-Reply-To: <20090706.114852.196263142.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 06 Jul 2009 11:48:52 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
> Date: Mon, 6 Jul 2009 20:02:14 +0930
> 
> > Will my first econet patch go in? It was just a "no magic numbers"
> > patch, unrelated to the NET_RX_DROP vs NET_RX_BAD issue.
> 
> I'm happy to apply that one, could you please resend it
> to the list?  That would make my life easier, thanks!

Done, as a non-thread email.

Regards,
Mark.

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
