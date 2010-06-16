From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipfrag : frag_kfree_skb() cleanup
Date: Tue, 15 Jun 2010 18:13:08 -0700 (PDT)
Message-ID: <20100615.181308.52197875.davem@davemloft.net>
References: <1276507363.2478.43.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49428
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752831Ab0FPBM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 21:12:56 -0400
In-Reply-To: <1276507363.2478.43.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 14 Jun 2010 11:22:43 +0200

> Third param (work) is unused, remove it.
> 
> Remove __inline__ and inline qualifiers.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
