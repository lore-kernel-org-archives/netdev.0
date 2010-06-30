From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ipv6: Use interface max_desync_factor instead of
 static default
Date: Wed, 30 Jun 2010 10:29:02 -0700 (PDT)
Message-ID: <20100630.102902.148553067.davem@davemloft.net>
References: <1277588267.26161.300.camel@localhost>
	<1277588575.26161.311.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, kaber@trash.net, 514646@bugs.debian.org,
	piotr.lewandowski@gmail.com, netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38887
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756997Ab0F3R2t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 13:28:49 -0400
In-Reply-To: <1277588575.26161.311.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Sat, 26 Jun 2010 22:42:55 +0100

> max_desync_factor can be configured per-interface, but nothing is
> using the value.
> 
> Reported-by: Piotr Lewandowski <piotr.lewandowski@gmail.com>
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Applied to net-next-2.6
