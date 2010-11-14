From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] pull linux-2.6 into net-next-2.6 ?
Date: Sun, 14 Nov 2010 12:21:31 -0800 (PST)
Message-ID: <20101114.122131.189716209.davem@davemloft.net>
References: <1289636478.2743.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51941
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932083Ab0KNUVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Nov 2010 15:21:06 -0500
In-Reply-To: <1289636478.2743.19.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 13 Nov 2010 09:21:18 +0100

> Andrew pushed to Linus the patch introducing atomic_inc_not_zero_hint()
> 
> (commit 3f9d35b9514da675)
> 
> Would it be possible to get it in net-next-2.6 so that I can start using
> it in network stack ?

Done.
