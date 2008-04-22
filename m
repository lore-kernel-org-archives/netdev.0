From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [bug] build failure in net/netfilter/nf_conntrack_sip.c, on	latest -git
Date: Tue, 22 Apr 2008 10:20:44 +0800
Message-ID: <E1Jo87g-0004HT-00@gondolin.me.apana.org.au>
References: <20080421133953.GJ9554@elte.hu>
Cc: jeff@garzik.org, davem@davemloft.net, linux-kernel@vger.kernel.org,
	kaber@trash.net, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org
To: mingo@elte.hu (Ingo Molnar)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58048 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756106AbYDVCVM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 22:21:12 -0400
In-Reply-To: <20080421133953.GJ9554@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar <mingo@elte.hu> wrote:
>
> but the only information i had at that point was that 'something in that 
> recent appearance of a large group of networking commits introduced the 
> problem'. There was no commit log entry of even the merge.

It is human nature to blame someone/something when things go wrong.
It just happens that the lack of a merge request was the first you
tacked onto in this case :)

I don't think we can seriously argue that had there been a merge
request on lkml that these build issues would have somehow gone
away or resolved any sooner than they have been.  The fact is
with or without the merge request you would have realised that
network bug reports == davem :)

> no. I simply failed to put this (trivial) bugreport into some sort of 
> existing context of discussion, and made a brief and neutral(-looking) 
> comment about that. Under no other development style could i have done 
> that because the context was simply missing from the mailing lists.

Unfortunately the email medium tends to make what one thinks of as
a neutral and balanced critique appear anything but to the recipient.
And I must say that in this case your messages did have that
appearance.

My only suggestion is for us to all move on to something a little
bit more useful than letting off steam.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
