From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] FIXED: IPv6 Route selection now correct with multiple
 gateways and preferences
Date: Tue, 14 Oct 2008 13:15:11 -0700 (PDT)
Message-ID: <20081014.131511.111914588.davem@davemloft.net>
References: <159769323.20081014120620@net.ipl.pt>
	<87y70rxri6.fsf@natisbad.org>
	<1316147719.20081014210732@net.ipl.pt>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arno@natisbad.org, yoshfuji@linux-ipv6.org
To: pribeiro-bulk@net.ipl.pt
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57496
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752197AbYJNUPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 16:15:37 -0400
In-Reply-To: <1316147719.20081014210732@net.ipl.pt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pedro Ribeiro <pribeiro-bulk@net.ipl.pt>
Date: Tue, 14 Oct 2008 21:07:32 +0100

> Can any of the maintainers give-me some expectations of when (and
> if) this fix will be added to a kernel release?

Well, first of all, your email client corrupted the patch (turning
tab characters into spaces etc.) so that is the first thing you
need to fix before we'll even look at this.
