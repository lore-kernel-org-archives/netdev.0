From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netpoll: remove CONFIG_NETPOLL_RX
Date: Sat, 28 Apr 2007 20:59:09 -0700 (PDT)
Message-ID: <20070428.205909.112852024.davem@davemloft.net>
References: <200704282248.52072.sshtylyov@ru.mvista.com>
	<200704282252.36591.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	mpm@selenic.com
To: sshtylyov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51445
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754553AbXD2D7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2007 23:59:00 -0400
In-Reply-To: <200704282252.36591.sshtylyov@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Date: Sat, 28 Apr 2007 22:52:36 +0400

> On Saturday 28 April 2007 22:48, Sergei Shtylyov wrote:
> > Get rid of the CONFIG_NETPOLL_RX option completely since all the
> > dependencies have been removed long ago...
> 
>    Same here:
> 
> > Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>
> Acked-by: Jeff Garzik <jgarzik@pobox.com>
> Acked-by: Matt Mackall <mpm@selenic.com>

Applied, thanks.
