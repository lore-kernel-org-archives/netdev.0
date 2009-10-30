From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: use hlist_for_each_entry()
Date: Fri, 30 Oct 2009 01:40:21 -0700 (PDT)
Message-ID: <20091030.014021.144215920.davem@davemloft.net>
References: <4AEAA5DD.3040704@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57242
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756305AbZJ3Ij5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 04:39:57 -0400
In-Reply-To: <4AEAA5DD.3040704@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 30 Oct 2009 09:37:49 +0100

> Small cleanup of __dev_get_by_name() and __dev_get_by_index()
> to use hlist_for_each_entry() : They'll look like their _rcu variant.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
