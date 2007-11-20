From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 0/4] Convert IP4 address class macros to
 inline functions
Date: Tue, 20 Nov 2007 00:03:13 -0800 (PST)
Message-ID: <20071120.000313.49219676.davem@davemloft.net>
References: <1195540812.4675.89.camel@localhost>
	<20071120070601.GE10490@verge.net.au>
	<1195543124.4675.114.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: horms@verge.net.au, netdev@vger.kernel.org, pekkas@netcore.fi,
	kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, jmorris@namei.org,
	kaber@coreworks.de
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43757
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751527AbXKTIDO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 03:03:14 -0500
In-Reply-To: <1195543124.4675.114.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 19 Nov 2007 23:18:44 -0800

> On Tue, 2007-11-20 at 16:06 +0900, Simon Horman wrote:
> > Also, as the function names are longer than the macro name
> > you are creating lines that are > 80 columns wide that used
> > not to be in that state. For my eyes that reduced readability
> > (substantially).
> 
> David? You want a patch for that too?

These patches are just clumsy and awkward, this much I will
say.

BTW, these seemingly odd macro names come from BSD.
Terefore they are quite readable for many of us :-)

I don't know what to do with these patches, they feel like
just plain noise to me even though I like the type checking.

I'm going to defer for now, sorry.
