From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: sch_sfq: revert "dump a real number of
	flows" patch
Date: Sat, 26 Jul 2008 12:58:26 +0200
Message-ID: <20080726105826.GB2524@ami.dom.local>
References: <20080724094908.GA3946@ff.dom.local> <488851FB.4080407@trash.net> <20080724105352.GB3946@ff.dom.local> <20080726.022927.258834159.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, denys@visp.net.lb, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:13799 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751487AbYGZK6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jul 2008 06:58:34 -0400
Received: by ug-out-1314.google.com with SMTP id h2so56319ugf.16
        for <netdev@vger.kernel.org>; Sat, 26 Jul 2008 03:58:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080726.022927.258834159.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 26, 2008 at 02:29:27AM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Thu, 24 Jul 2008 10:53:52 +0000
> 
> > On Thu, Jul 24, 2008 at 11:57:15AM +0200, Patrick McHardy wrote:
> > ...
> > > IIRC the ESFQ for SFQ patches even use
> > > "flows" in ->init, so it might make things a bit more ugly if we
> > > ever merge those patches.
> > 
> > This argument looks right to me.
> > 
> > David, please, apply this reverting patch.
> 
> I've reverted the changeset using "git revert".
> 

Is it legal now? (I've seen this in Linus' tree already...)

Thanks,
Jarek P.
