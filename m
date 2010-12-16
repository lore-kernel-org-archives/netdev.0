From: David Miller <davem@davemloft.net>
Subject: Re: pktgen IP address stepping
Date: Thu, 16 Dec 2010 10:34:33 -0800 (PST)
Message-ID: <20101216.103433.189689586.davem@davemloft.net>
References: <20101216172800.GA8404@spritelink.se>
	<20101216.094426.193723178.davem@davemloft.net>
	<20101216182724.GB8404@spritelink.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kristian@spritelink.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41923
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756990Ab0LPSeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 13:34:04 -0500
In-Reply-To: <20101216182724.GB8404@spritelink.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kristian Larsson <kristian@spritelink.net>
Date: Thu, 16 Dec 2010 19:27:24 +0100

> And given your comment I suppose u32 is a better choice than
> "unsigned long", right? 

Yes.
