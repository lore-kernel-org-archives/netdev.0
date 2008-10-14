From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH for 2.6.27] Structure icmp6hdr (IPv6/ICMPv6) with bug
 in the bitfields!
Date: Tue, 14 Oct 2008 15:47:16 -0700 (PDT)
Message-ID: <20081014.154716.139460375.davem@davemloft.net>
References: <159769323.20081014120620@net.ipl.pt>
	<20081014.135423.91524319.davem@davemloft.net>
	<1338007712.20081014233811@net.ipl.pt>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pribeiro-bulk@net.ipl.pt
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50789
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751388AbYJNWrk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 18:47:40 -0400
In-Reply-To: <1338007712.20081014233811@net.ipl.pt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pedro Ribeiro <pribeiro-bulk@net.ipl.pt>
Date: Tue, 14 Oct 2008 23:38:11 +0100

> Hello David,
> 
> Thanks for your time on this, follows a new patch made against 2.6.27,
> this time I minimized the cut&paste to avoid corrupting the patch.

It's still corrupted, the tab characters in the patch were
transformed into spaces.

It's not about cut&paste, your email client is reformatting the
content (no matter how you compose it) before sending it out.

You need to configure your email client explicitly to not reformat the
content and to use plain ASCII text.

Also, you need to provide a proper "Signed-off-by: " line.

All of this is detailed in the following kernel source doc
files:

linux/Documentation/email-clients.txt
linux/Documentation/SubmittingPatches 

Thanks.
