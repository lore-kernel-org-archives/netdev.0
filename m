From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] napi: limit GRO latency
Date: Mon, 8 Oct 2012 12:40:26 -0700
Message-ID: <20121008124026.4057aba8@nehalam.linuxnetplumber.net>
References: <1349718955.21172.3534.camel@edumazet-glaptop>
	<1349719006.21172.3537.camel@edumazet-glaptop>
	<20121008115835.3a3bfed6@nehalam.linuxnetplumber.net>
	<20121008.151035.1665672334154033755.davem@davemloft.net>
	<20121008121248.783e6dc4@nehalam.linuxnetplumber.net>
	<1349724612.21172.3643.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	jesse@nicira.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41249 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751172Ab2JHTlG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2012 15:41:06 -0400
In-Reply-To: <1349724612.21172.3643.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 08 Oct 2012 21:30:12 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> System is under stress, you dont want to increase load at this point,
> but increase bandwidth.
> 
> Really try this on a 40Gbe link and see how bad it is.

Not everybody has 40Gbe hardware just lying around available for testing :-)
