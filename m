From: David Miller <davem@davemloft.net>
Subject: Re: [NET_SCHED]: cls_basic: fix memory leak in basic_destroy
Date: Fri, 30 Mar 2007 13:41:23 -0700 (PDT)
Message-ID: <20070330.134123.32346899.davem@davemloft.net>
References: <460D42BD.6020500@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39619
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753607AbXC3Ulb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2007 16:41:31 -0400
In-Reply-To: <460D42BD.6020500@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 30 Mar 2007 19:02:53 +0200

> [NET_SCHED]: cls_basic: fix memory leak in basic_destroy
> 
> tp->root is not freed on destruction.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks a lot Patrick.
