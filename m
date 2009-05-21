From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: HTB accuracy for high speed
Date: Thu, 21 May 2009 11:22:12 +0200
Message-ID: <20090521092212.GA3248@ami.dom.local>
References: <1242689267.11814.1.camel@hazard2.francoudi.com> <20090519110311.GA5521@ff.dom.local> <20090519140416.GA21270@francoudi.com> <20090519201027.GA4751@ami.dom.local> <1242857245.13519.17.camel@hazard2.francoudi.com> <4A148838.8010809@cosmosbay.com> <20090521072050.GA2892@ami.dom.local> <20090521074400.GA19113@francoudi.com> <20090521082805.GB2892@ami.dom.local> <4A1519CC.9030002@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vladimir Ivashchenko <hazard@francoudi.com>,
	netdev@vger.kernel.org, kaber@trash.net, davem@davemloft.net,
	devik@cdi.cz, Antonio Almeida <vexwek@gmail.com>,
	Corey Hickey <bugfood-ml@fatooh.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f222.google.com ([209.85.218.222]:44598 "EHLO
	mail-bw0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782AbZEUJWX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2009 05:22:23 -0400
Received: by bwz22 with SMTP id 22so888087bwz.37
        for <netdev@vger.kernel.org>; Thu, 21 May 2009 02:22:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A1519CC.9030002@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 21, 2009 at 11:07:24AM +0200, Eric Dumazet wrote:
...
> > - gso/tso or other non standard packets sizes - for exceeding the
> >   rate.
> 
> Could we detect this at runtime and emit a warning (once) ?

I guess, it's a rhetorical question...

Jarek P.
