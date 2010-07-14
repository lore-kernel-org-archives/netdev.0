From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/11] Removing dead REDWOOD_{5,6}
Date: Wed, 14 Jul 2010 13:44:15 -0700 (PDT)
Message-ID: <20100714.134415.183043981.davem@davemloft.net>
References: <cover.1279110894.git.siccegge@cs.fau.de>
	<adba61f63f4439ac17f2e428429f01ae5e65ab15.1279110895.git.siccegge@cs.fau.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nico@fluxnic.net, tony@atomide.com, dwalker@codeaurora.org,
	rubini@unipv.it, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	vamos-dev@i4.informatik.uni-erlangen.de
To: siccegge@cs.fau.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41024
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757333Ab0GNUoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 16:44:00 -0400
In-Reply-To: <adba61f63f4439ac17f2e428429f01ae5e65ab15.1279110895.git.siccegge@cs.fau.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Egger <siccegge@cs.fau.de>
Date: Wed, 14 Jul 2010 14:41:31 +0200

> REDWOOD_{5,6} doesn't exist in Kconfig, therefore removing all
> references for it from the source code.
> 
> Signed-off-by: Christoph Egger <siccegge@cs.fau.de>

Again, if you're going to kill this off you should also delete the
references in drivers/net/Kconfig at the same time.

Please fix this up and resubmit your patch, thanks.
