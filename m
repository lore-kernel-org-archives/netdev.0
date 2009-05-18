From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipv4: cleanup: remove unnecessary include.
Date: Mon, 18 May 2009 15:17:13 -0700 (PDT)
Message-ID: <20090518.151713.265656651.davem@davemloft.net>
References: <eb3ff54b0905180447y7f3d1f0aof0203be26dd3bcdb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41547
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754745AbZERWRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 18:17:15 -0400
In-Reply-To: <eb3ff54b0905180447y7f3d1f0aof0203be26dd3bcdb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>
Date: Mon, 18 May 2009 14:47:52 +0300

> There is no need for net/icmp.h header in net/ipv4/fib_frontend.c.
> This patch removes the #include net/icmp.h from it.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied.
