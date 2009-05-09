From: David Miller <davem@davemloft.net>
Subject: Re: decnet: Use data ready call back, rather than hand coding it
Date: Sat, 09 May 2009 13:18:30 -0700 (PDT)
Message-ID: <20090509.131830.01270908.davem@davemloft.net>
References: <1241800225.29604.282.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ccaulfie@redhat.com, netdev@vger.kernel.org
To: swhiteho@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43100
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754186AbZEIUSe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2009 16:18:34 -0400
In-Reply-To: <1241800225.29604.282.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steven Whitehouse <swhiteho@redhat.com>
Date: Fri, 08 May 2009 17:30:25 +0100

> Chrissie, can you test this? I don't have a suitable set up at the
> moment. This should be correct though since its taken directly from
> sock_queue_rcv_skb from whence the original code was also take in times
> past. I did compile test it though.
> 
> Signed-off-by: Steven Whitehouse <swhiteho@redhat.com>

I'm tossing this into net-next-2.6 now, if there is some bug
we can add a follow-on fix.

Thanks!
