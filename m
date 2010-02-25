From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: tipc: Fix oops on send prior to entering networked
 mode
Date: Thu, 25 Feb 2010 07:06:20 -0800 (PST)
Message-ID: <20100225.070620.236234509.davem@davemloft.net>
References: <20100224211507.GC15380@hmsreliant.think-freely.org>
	<20100224.173811.264809559.davem@davemloft.net>
	<29C1DC0826876849BDD9F1C67ABA2943070F1849@ala-mail09.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
	jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net,
	hadi@cyberus.ca
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60596
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759037Ab0BYPGC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2010 10:06:02 -0500
In-Reply-To: <29C1DC0826876849BDD9F1C67ABA2943070F1849@ala-mail09.corp.ad.wrs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Stephens, Allan" <allan.stephens@windriver.com>
Date: Thu, 25 Feb 2010 06:24:15 -0800

> PS. I'm holding back on replying to other previous emails from David and
> Neil in this thread since deciding how to fix the oops that triggered
> this whole discussion depends on whether or not we're going to integrate
> the rest of TIPC 1.7 or not.

Are you out of your mind?

We're fixing the OOPS in the smallest and most expediant way
possible.

Integrating all of TIPC 1.7 to fix this OOPS is utter and pure
insanity.
