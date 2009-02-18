From: David Miller <davem@davemloft.net>
Subject: Re: [RFT 2/4] Add mod_timer_noact
Date: Wed, 18 Feb 2009 14:04:55 -0800 (PST)
Message-ID: <20090218.140455.142445208.davem@davemloft.net>
References: <20090218110144.GA4100@elte.hu>
	<20090218.133959.193699273.davem@davemloft.net>
	<20090218215140.GA3505@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, kaber@trash.net, rick.jones2@hp.com,
	dada1@cosmosbay.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, tglx@linutronix.de,
	gandalf@wlug.westbo.se, linux-kernel@vger.kernel.org
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50973
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752230AbZBRWFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 17:05:10 -0500
In-Reply-To: <20090218215140.GA3505@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Wed, 18 Feb 2009 22:51:40 +0100

> Anyway, it's all handled, you just need to read the rest of the 
> thread.

I did read the entire thread before replying, my objection
to your original posting still standed.

And as others have pointed out you also failed to recognize
the context of the patch posting.  It was part of a sequence
of patches for people to test some experimental netfilter
performance optimizations.  "RFT" was prefixed to every patch
subject line, if any more indication was necessary.

Yet you object that the patches are against the networking
and netfilter trees.

Again, your reactions were knee-jerk, by every definition of the
term.

I know how you work Ingo, you want to be fast and efficient.
But often, your "fast and efficient" is "careless", and this
wastes everyone elses time and in the final analysis makes
you "slow".
