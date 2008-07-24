From: David Miller <davem@davemloft.net>
Subject: Re: [regression] nf_iterate(), BUG: unable to handle kernel NULL
 pointer dereference
Date: Thu, 24 Jul 2008 13:58:10 -0700 (PDT)
Message-ID: <20080724.135810.235355036.davem@davemloft.net>
References: <1216906476.12021.4.camel@penberg-laptop>
	<20080724115127.6cfbb616.akpm@linux-foundation.org>
	<1216925744.12392.1.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, kaber@trash.net, mingo@elte.hu,
	herbert@gondor.apana.org.au, w@1wt.eu, davidn@davidnewall.com,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stefanr@s5r6.in-berlin.de,
	rjw@sisk.pl, ilpo.jarvinen@helsinki.fi, davej@redhat.com,
	clip2@gmx.de, vegard.nossum@gmail.com
To: penberg@cs.helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56182
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751301AbYGXU6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 16:58:10 -0400
In-Reply-To: <1216925744.12392.1.camel@penberg-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pekka Enberg <penberg@cs.helsinki.fi>
Date: Thu, 24 Jul 2008 21:55:44 +0300

> On Thu, 2008-07-24 at 11:51 -0700, Andrew Morton wrote:
> > Sure.  Or Patrick can do so and it can be merged via the net tree.
> > 
> > Ingo, did this patch actually fix something over there?
> 
> Apparently it didn't but it did fix Dieter's problem:
> 
> http://lkml.org/lkml/2008/7/24/337
> 
> Dieter, can we add a Tested-by tag from you to this patch?

Patrick will toss it my way, and it'll get integrated
via net-2.6 as a result.
