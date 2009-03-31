From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 ] ipv4: remove unused parameter from
 tcp_recv_urg().
Date: Tue, 31 Mar 2009 14:43:25 -0700 (PDT)
Message-ID: <20090331.144325.74619523.davem@davemloft.net>
References: <eb3ff54b0903300711l34b6f883kda27683b344bbcac@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51935
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751022AbZCaVng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 17:43:36 -0400
In-Reply-To: <eb3ff54b0903300711l34b6f883kda27683b344bbcac@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>
Date: Mon, 30 Mar 2009 17:11:30 +0300

> This patch removes an unused parameter (timeo) from tcp_recv_urg() method in
> net/ipv4/tcp.c.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied.
