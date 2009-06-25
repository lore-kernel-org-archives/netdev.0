From: David Miller <davem@davemloft.net>
Subject: Re: PATCH: ipv6: avoid wraparound for expired lifetimes
Date: Thu, 25 Jun 2009 02:33:13 -0700 (PDT)
Message-ID: <20090625.023313.03220230.davem@davemloft.net>
References: <20090625073943.GO21357@jayr.de>
	<Pine.LNX.4.64.0906251135410.917@melkinkari.cs.Helsinki.FI>
	<20090625090603.GP21357@jayr.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: me@jayr.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57323
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753106AbZFYJdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2009 05:33:08 -0400
In-Reply-To: <20090625090603.GP21357@jayr.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jens Rosenboom <me@jayr.de>
Date: Thu, 25 Jun 2009 11:06:03 +0200

> Sorry for that, here is the correct version.

Please don't resend just the patch, make a formal fresh
submission, commit message and all.

That way it's get properly tracked as a unit on:

	http://patchwork.ozlabs.org/project/netdev/list/

If you just send the patch I have to go back through the list
archives, find your original changelog message, and then piece them
together with this new patch.  Which make unnecessarily more work for
me.
