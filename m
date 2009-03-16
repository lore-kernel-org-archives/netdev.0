From: Tom Herbert <therbert@google.com>
Subject: Re: [RFC v2: Patch 1/3] net: hand off skb list to other cpu to submit
	to upper layer
Date: Mon, 16 Mar 2009 09:53:47 -0700
Message-ID: <65634d660903160953o563385f8p29c0da5e3128f6f@mail.gmail.com>
References: <65634d660903131724s49009177pdc11005aa76a4b56@mail.gmail.com>
	 <20090313.191951.228619450.davem@davemloft.net>
	 <65634d660903141115w7e164134ycece307f041e93a9@mail.gmail.com>
	 <20090314.114522.19720687.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yanmin_zhang@linux.intel.com, bhutchings@solarflare.com,
	andi@firstfloor.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, herbert@gondor.apana.org.au,
	jesse.brandeburg@intel.com, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:28710 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754961AbZCPQxy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2009 12:53:54 -0400
In-Reply-To: <20090314.114522.19720687.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 14, 2009 at 11:45 AM, David Miller <davem@davemloft.net> wr=
ote:
>
> From: Tom Herbert <therbert@google.com>
> Date: Sat, 14 Mar 2009 11:15:21 -0700
>
> > I suppose it may be counter-intuitive, but I am not making a genera=
l
> > claim. =A0I would only suggest that these software hacks could be a=
 very
> > good approximation or substitute for hardware functionality. =A0Thi=
s is
> > a generic way to get more performance out of deficient or lower end
> > NICs.
>
> They certainly could. =A0Why don't you post the current version
> of your patches so we have something concrete to discuss?

I'll do that.
