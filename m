From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv2] gro: Name the GRO result enumeration type
Date: Fri, 30 Oct 2009 11:48:18 +0000
Message-ID: <1256903298.3136.261.camel@localhost>
References: <1256840061.2827.80.camel@achroite>
	 <1256840775.2827.83.camel@achroite>
	 <20091029.213223.94736944.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:20118 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756671AbZJ3LsR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 07:48:17 -0400
In-Reply-To: <20091029.213223.94736944.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-10-29 at 21:32 -0700, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Thu, 29 Oct 2009 18:26:15 +0000
> 
> > This clarifies which return and parameter types are GRO result codes
> > and not RX result codes.
> > 
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> > ---
> > This replaces the previous patch 1/4 and avoids introducing compiler
> > warnings.  The original patches 2-4 will still apply on top of it.
> 
> You can't do this Ben.
> 
> Changing this patch makes the follow-on patches not apply cleanly.
[...]

I'm sorry about that - a git rebase succeeded without manual attention,
so I believed they did.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

