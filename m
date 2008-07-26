From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [regression] nf_iterate(), BUG: unable to handle kernel NULL
	pointer dereference
Date: Sat, 26 Jul 2008 19:34:50 +0200
Message-ID: <20080726173450.GA2242@elte.hu>
References: <20080724115957.GA25701@elte.hu> <48886FA6.6050908@trash.net> <84144f020807240544q507e1b7cv220d1afbae0ee0f0@mail.gmail.com> <48887A71.5010209@trash.net> <1216905812.5897.6.camel@penberg-laptop> <48888434.3030207@trash.net> <1216906476.12021.4.camel@penberg-laptop> <20080724115127.6cfbb616.akpm@linux-foundation.org> <20080724193532.GC1694@elte.hu> <488B4C1D.3020506@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	David Miller <davem@davemloft.net>,
	herbert@gondor.apana.org.au, w@1wt.eu, davidn@davidnewall.com,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stefanr@s5r6.in-berlin.de,
	rjw@sisk.pl, ilpo.jarvinen@helsinki.fi,
	Dave Jones <davej@redhat.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:46309 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753445AbYGZRgS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Jul 2008 13:36:18 -0400
Content-Disposition: inline
In-Reply-To: <488B4C1D.3020506@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Patrick McHardy <kaber@trash.net> wrote:

> Ingo Molnar wrote:
>> * Andrew Morton <akpm@linux-foundation.org> wrote:
>>
>>> Ingo, did this patch actually fix something over there?
>>
>> not that i know of. I'll do some re-tests tomorrow to make sure.
>
> I managed to reproduce the bug you reported, but it reliably goes away 
> if I add Pekka's patch. Did you get a chance to retest already?

not yet - please consider it fixed, i'll let you know if something 
similar to that occurs.

	Ingo
