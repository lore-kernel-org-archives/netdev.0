From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] 3c59x: Fix deadlock in vortex_error()
Date: Mon, 06 Sep 2010 18:29:08 -0700 (PDT)
Message-ID: <20100906.182908.200386818.davem@davemloft.net>
References: <1283822830.5323.562.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgs@trash.net, 595554@bugs.debian.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50271
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755655Ab0IGB2u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 21:28:50 -0400
In-Reply-To: <1283822830.5323.562.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Tue, 07 Sep 2010 02:27:10 +0100

> This is the regression I mentioned before.  3c59x should be good after
> this.

Excellent, applied, thanks!
