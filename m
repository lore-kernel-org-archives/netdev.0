From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: sch_sfq: revert "dump a real number of
 flows" patch
Date: Sat, 26 Jul 2008 02:29:27 -0700 (PDT)
Message-ID: <20080726.022927.258834159.davem@davemloft.net>
References: <20080724094908.GA3946@ff.dom.local>
	<488851FB.4080407@trash.net>
	<20080724105352.GB3946@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, denys@visp.net.lb, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44137
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751611AbYGZJ32 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jul 2008 05:29:28 -0400
In-Reply-To: <20080724105352.GB3946@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Thu, 24 Jul 2008 10:53:52 +0000

> On Thu, Jul 24, 2008 at 11:57:15AM +0200, Patrick McHardy wrote:
> ...
> > IIRC the ESFQ for SFQ patches even use
> > "flows" in ->init, so it might make things a bit more ugly if we
> > ever merge those patches.
> 
> This argument looks right to me.
> 
> David, please, apply this reverting patch.

I've reverted the changeset using "git revert".

Thanks!
