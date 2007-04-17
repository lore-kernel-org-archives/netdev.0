From: David Miller <davem@davemloft.net>
Subject: Re: [NET_SCHED]: ingress: switch back to using ingress_lock
Date: Mon, 16 Apr 2007 17:07:38 -0700 (PDT)
Message-ID: <20070416.170738.39325820.davem@davemloft.net>
References: <46232B93.1000807@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58437
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754045AbXDQAHh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 20:07:37 -0400
In-Reply-To: <46232B93.1000807@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 16 Apr 2007 09:53:55 +0200

> This patch fixes a few spots for using ingress_lock for the ingress
> qdisc again and switches ing_filter back to use it.
> 
> Applies on top of the netlink dump patches.

Applied, thanks a lot for following up on this ingress locking
issue Patrick.
