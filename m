From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] softirq: tasklet_hrtimer
Date: Wed, 22 Jul 2009 09:01:09 -0700 (PDT)
Message-ID: <alpine.LFD.2.01.0907220900250.19335@localhost.localdomain>
References: <1247588890.7500.186.camel@twins>  <alpine.LFD.2.01.0907140940440.13838@localhost.localdomain>  <1247832892.15751.35.camel@twins>  <20090721.201855.32703627.davem@davemloft.net> <1248265724.27058.1366.camel@twins>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, tglx@linutronix.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kaber@trash.net
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48584 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751288AbZGVQCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2009 12:02:35 -0400
In-Reply-To: <1248265724.27058.1366.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 22 Jul 2009, Peter Zijlstra wrote:
>
> Stick tasklets and hrtimers together to provide an in-softirq hrtimer
> experience.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

Looks ok by me now.

Acked-by: Linus Torvalds <torvalds@linux-foundation.org>

	Thanks,
		Linus
