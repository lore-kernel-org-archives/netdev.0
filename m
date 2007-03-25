From: David Miller <davem@davemloft.net>
Subject: Re: [NET_SCHED]: cls_basic: fix NULL pointer dereference
Date: Sat, 24 Mar 2007 22:14:07 -0700 (PDT)
Message-ID: <20070324.221407.90122747.davem@davemloft.net>
References: <46001694.9090402@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadi@cyberus.ca
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36554
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933148AbXCYFOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Mar 2007 01:14:08 -0400
In-Reply-To: <46001694.9090402@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 20 Mar 2007 18:15:00 +0100

> These two patches fix the cls_basic crash reported by Chris
> Madden and the ingress locking problem.
> 
> Please apply, thanks.

Applied, I'll push to -stable, thanks!
