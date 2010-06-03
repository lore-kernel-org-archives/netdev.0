From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: use __packed annotation
Date: Thu, 03 Jun 2010 03:22:03 -0700 (PDT)
Message-ID: <20100603.032203.181452674.davem@davemloft.net>
References: <1275517209.29413.41.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55476
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933555Ab0FCKVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 06:21:54 -0400
In-Reply-To: <1275517209.29413.41.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 Jun 2010 00:20:09 +0200

> cleanup patch.
> 
> Use new __packed annotation in net/ and include/
> (except netfilter)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
