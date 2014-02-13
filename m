From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] ipv4: arp: process only if ipv4 address configured
Date: Thu, 13 Feb 2014 09:56:07 +0100
Message-ID: <20140213085607.GE25153@breakpoint.cc>
References: <1392226067-21736-1-git-send-email-fw@strlen.de>
 <20140213002413.GK11150@order.stressinduktion.org>
 <20140212.192520.955911778570827692.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hannes@stressinduktion.org, fw@strlen.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:42390 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752519AbaBMI4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 03:56:12 -0500
Content-Disposition: inline
In-Reply-To: <20140212.192520.955911778570827692.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Thu, 13 Feb 2014 01:24:13 +0100
> 
> > I actually expect arp answers for ip addresses bound to loopback even from an
> > interface without ip address, if we strictly conform to the week end host
> > model in linux.
> 
> Agreed.

Thanks for your inpout everyone.  I've self-rejected the patch.
