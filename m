From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 3/3] netxen: fix infinite loop on dma mapping
 failure
Date: Thu, 03 Sep 2009 20:07:26 -0700 (PDT)
Message-ID: <20090903.200726.104650791.davem@davemloft.net>
References: <1252019455-30683-1-git-send-email-dhananjay@netxen.com>
	<1252019455-30683-3-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.com, netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50999
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932744AbZIDDHL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 23:07:11 -0400
In-Reply-To: <1252019455-30683-3-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Thu,  3 Sep 2009 16:10:55 -0700

> Fix a perpetual while() loop in unwinding partial
> mapped tx skb on dma mapping failure.
> 
> Reported-by: "Juha Leppanen" <juha_motorsportcom@luukku.com>
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied.
