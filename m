From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/14] Add common OF device tree support for MDIO busses
Date: Tue, 31 Mar 2009 15:22:37 -0700 (PDT)
Message-ID: <20090331.152237.210090951.davem@davemloft.net>
References: <20090331075537.1427.7819.stgit@localhost.localdomain>
	<20090331.145738.36845509.davem@davemloft.net>
	<fa686aa40903311519m3108c697v52180d192975a3b1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, olof@lixom.net,
	afleming@freescale.com, galak@kernel.crashing.org,
	avorontsov@ru.mvista.com, Joakim.Tjernlund@transmode.se
To: grant.likely@secretlab.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41317
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755530AbZCaWWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 18:22:51 -0400
In-Reply-To: <fa686aa40903311519m3108c697v52180d192975a3b1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>
Date: Tue, 31 Mar 2009 16:19:42 -0600

> On Tue, Mar 31, 2009 at 3:57 PM, David Miller <davem@davemloft.net> wrote:
> > It therefore didn't get any -next exposure, so it's unreasonable to
> > merge this stuff now.
> 
> Since when has sitting in a -next tree been a requirement for merging
> when the series has been kept up to date and tested?  I purposefully
> kept it out of -next to ensure that when it was applied for real to a
> -next tree it would be as complete, bug free, and bisectable as
> possible since once it hits a signed-off -next branch the individual
> commit cannot be modified.

I know your pissed off, but take a deep breath and consider this
from my position.

If I don't put a line in the sand somewhere, everyone can say
"I've been working so hard, I posted it to the lists a thousand
times, I have tons of testers" and I have to put the change in.

That doesn't work, so please wait until the next release to get
your changes in.  And get them into a tree that gets exposure
in linux-next.  Then you have nothing to worry about.

Thank you.
