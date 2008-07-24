From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Re: SFQ depth limit
Date: Wed, 23 Jul 2008 21:34:43 -0700 (PDT)
Message-ID: <20080723.213443.37820788.davem@davemloft.net>
References: <200806282202.59581.denys@visp.net.lb>
	<20080629191113.GA8817@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: denys@visp.net.lb, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42981
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752240AbYGXEen (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 00:34:43 -0400
In-Reply-To: <20080629191113.GA8817@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sun, 29 Jun 2008 21:11:13 +0200

> sch_sfq: dump a real number of flows
> 
> Dump the "flows" number according to the number of active flows
> instead of repeating the "limit".
> 
> 
> Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Looks reasonable, applied, thanks Jarek.
