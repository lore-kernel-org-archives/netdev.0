From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 05/15] dec netdev: relocate DIGITAL based drivers to
 legacy
Date: Thu, 28 Oct 2010 22:47:03 -0700 (PDT)
Message-ID: <20101028.224703.112589527.davem@davemloft.net>
References: <alpine.LFD.2.00.1010290516110.25426@eddie.linux-mips.org>
	<20101028.212939.189691515.davem@davemloft.net>
	<alpine.LFD.2.00.1010290545270.25426@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.gortmaker@windriver.com, netdev@vger.kernel.org
To: macro@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33297
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752357Ab0J2Fqk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 01:46:40 -0400
In-Reply-To: <alpine.LFD.2.00.1010290545270.25426@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Maciej W. Rozycki" <macro@linux-mips.org>
Date: Fri, 29 Oct 2010 05:54:56 +0100 (BST)

>  Hmm, what's the difference between placing these drivers here or there 
> and what's so particular about them that they cause clutter?  I mean a 
> mere high number of items does not cause a mess by itself -- the lack of 
> order might.
> 
>  Also -- if this change goes ahead -- when I add new TURBOchannel drivers, 
> should they go straight to legacy/?  It sounds odd to me to have a thing 
> obsolete straight from the beginning.

This patch series started with a "0/15" introduction posting which
explains the intention and reasoning.

It might be easier for you to read it instead of asking me to repeat
it's contents :-)
