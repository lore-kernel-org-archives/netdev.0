From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: sch_sfq: revert "dump a real number of
 flows" patch
Date: Sat, 26 Jul 2008 17:24:49 -0700 (PDT)
Message-ID: <20080726.172449.238799043.davem@davemloft.net>
References: <20080724105352.GB3946@ff.dom.local>
	<20080726.022927.258834159.davem@davemloft.net>
	<20080726105826.GB2524@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, denys@visp.net.lb, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46323
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753271AbYG0AYt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jul 2008 20:24:49 -0400
In-Reply-To: <20080726105826.GB2524@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sat, 26 Jul 2008 12:58:26 +0200

> On Sat, Jul 26, 2008 at 02:29:27AM -0700, David Miller wrote:
> > From: Jarek Poplawski <jarkao2@gmail.com>
> > Date: Thu, 24 Jul 2008 10:53:52 +0000
> > 
> > > On Thu, Jul 24, 2008 at 11:57:15AM +0200, Patrick McHardy wrote:
> > > ...
> > > > IIRC the ESFQ for SFQ patches even use
> > > > "flows" in ->init, so it might make things a bit more ugly if we
> > > > ever merge those patches.
> > > 
> > > This argument looks right to me.
> > > 
> > > David, please, apply this reverting patch.
> > 
> > I've reverted the changeset using "git revert".
> > 
> 
> Is it legal now? (I've seen this in Linus' tree already...)

Absolutely, the SHA IDs will match, it will work perfectly
fine.
