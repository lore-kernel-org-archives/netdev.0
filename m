From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v6] sctp: be more restrictive in transport selection on
 bundled sacks
Date: Tue, 3 Jul 2012 19:42:16 -0400
Message-ID: <20120703234216.GB10224@neilslaptop.think-freely.org>
References: <1341061466-4186-1-git-send-email-nhorman@tuxdriver.com>
 <20120630.173945.173993639982489712.davem@davemloft.net>
 <20120701124750.GA19498@neilslaptop.think-freely.org>
 <20120701.144319.1120248166079750922.davem@davemloft.net>
 <20120701234424.GA23935@neilslaptop.think-freely.org>
 <20120702122531.GA29681@hmsreliant.think-freely.org>
 <4FF33DBE.7060103@computer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	vyasevich@gmail.com, linux-sctp@vger.kernel.org
To: Jan Ceuleers <jan.ceuleers@computer.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:43596 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750731Ab2GCXm1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 19:42:27 -0400
Content-Disposition: inline
In-Reply-To: <4FF33DBE.7060103@computer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 03, 2012 at 08:45:18PM +0200, Jan Ceuleers wrote:
> On 07/02/2012 02:25 PM, Neil Horman wrote:
> ...
> 
> > How does this language sound to you?
> ...
> 
> > +tree maintanier may reapply the subsystem maintainers Acked-by: to the new
> 
> s/maintanier/maintainer/
> 
> HTH, Jan
Thanks Jan, I've fixed it in my local tree, it'll get rolled in the next
version. 
Neil

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
