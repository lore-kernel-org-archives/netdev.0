From: David Miller <davem@davemloft.net>
Subject: Re: fix-slab-corruption-running-ip6sic.patch
Date: Sat, 28 Apr 2007 21:26:57 -0700 (PDT)
Message-ID: <20070428.212657.00929702.davem@davemloft.net>
References: <20070426141133.21ef2e17.akpm@linux-foundation.org>
	<20070427071859.GD997@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, snakebyte@gmx.de
To: jarkao2@o2.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57630
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754570AbXD2E0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Apr 2007 00:26:48 -0400
In-Reply-To: <20070427071859.GD997@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarek Poplawski <jarkao2@o2.pl>
Date: Fri, 27 Apr 2007 09:18:59 +0200

> On Thu, Apr 26, 2007 at 02:11:33PM -0700, Andrew Morton wrote:
> > 
> > I have this floating about in my tree.  Is it of any interest?
> > 
> > 
> > 
> > From: Jarek Poplawski <jarkao2@o2.pl>
> 
> I know you've more interesting problems, but I'd like to
> straighten something: this is not my patch!
> 
> Please, change this to:
> 
> From: Eric Sesterhenn <snakebyte@gmx.de>

Patch applied, thanks everyone.
