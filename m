From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 11/11] netfilter warning fix
Date: Wed, 7 Feb 2007 09:18:48 +0100
Message-ID: <20070207081848.GA7247@elte.hu>
References: <20070206215806.GA5109@elte.hu> <45C974FD.5070404@trash.net> <20070207080722.GC2434@elte.hu> <20070207.001310.91210854.davem@davemloft.net> <45C98ACB.1080107@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, dipankar@in.ibm.com, paulmck@us.ibm.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:44252 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030374AbXBGITO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Feb 2007 03:19:14 -0500
Content-Disposition: inline
In-Reply-To: <45C98ACB.1080107@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Patrick McHardy <kaber@trash.net> wrote:

> David Miller wrote:
> > From: Ingo Molnar <mingo@elte.hu>
> > Date: Wed, 7 Feb 2007 09:07:22 +0100
> > 
> > 
> >>Dave, Patrick, can we lift the nack on PREEMPT_RCU, as far as networking 
> >>goes?
> > 
> > 
> > After Patrick's fixups, sure.
> 
> I'm about to send my queued netfilter patches, after which I will look 
> into this. Shouldn't take more than a one or two days.

thanks, that's great!

	Ingo
