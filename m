From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH][BNX2X] round three
Date: Mon, 15 Oct 2007 15:06:03 -0700
Message-ID: <20071015150603.62f5a37b@freepuppy.rosehill>
References: <1192462049.29746.158.camel@eliezer>
	<20071015.123850.26516814.davem@davemloft.net>
	<20071015145829.1acabefb@freepuppy.rosehill>
	<20071015.150022.30183587.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: eliezert@broadcom.com, andi@firstfloor.org, netdev@vger.kernel.org,
	jeff@garzik.org, mchan@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:33253 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751925AbXJOWGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 18:06:23 -0400
In-Reply-To: <20071015.150022.30183587.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 15 Oct 2007 15:00:22 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Mon, 15 Oct 2007 14:58:29 -0700
> 
> > What about using loadable firmware rather than building it into the driver?
> 
> Stephen, do me a huge favor, and don't start down that path.
> 
> Please...

I know the history, loadable firmware is a maintenance nuisance/nightmare.
And it often leads to stupid license crap.
---
Stephen Hemminger <shemminger@linux-foundation.org>
