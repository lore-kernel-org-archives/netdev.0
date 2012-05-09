From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: RE: [PATCH net-next 3/4] netxen: added miniDIMM support in driver.
Date: Wed, 9 May 2012 00:59:08 -0500
Message-ID: <13A253B3F9BEFE43B93C09CF75F63CAA81A8F3174A@MNEXMB1.qlogic.org>
References: <1336489288-22347-1-git-send-email-rajesh.borundia@qlogic.com>
	<1336489288-22347-4-git-send-email-rajesh.borundia@qlogic.com>
 <20120508.125311.1669426371305176333.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe006.messaging.microsoft.com ([216.32.181.186]:45748
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756547Ab2EIF7Y convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2012 01:59:24 -0400
In-Reply-To: <20120508.125311.1669426371305176333.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, May 08, 2012 10:23 PM
> To: Rajesh Borundia
> Cc: netdev; Ameen Rahman; Sony Chacko; Sucheta Chakraborty
> Subject: Re: [PATCH net-next 3/4] netxen: added miniDIMM support in
> driver.
> 
> From: Rajesh Borundia <rajesh.borundia@qlogic.com>
> Date: Tue, 8 May 2012 08:01:27 -0700
> 
> > +static struct bin_attribute bin_attr_dimm = {
> > +	.attr = {.name = "dimm", .mode = (S_IRUGO | S_IWUSR)},
> 
> How about a space next to the braces?
> 

I will resend the patches with review changes.

Rajesh
