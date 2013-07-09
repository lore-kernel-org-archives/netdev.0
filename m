From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Mon, 8 Jul 2013 19:48:17 -0700
Message-ID: <20130708194817.34503460.akpm@linux-foundation.org>
References: <20130707.132133.1335860703202153192.davem@davemloft.net>
	<CA+55aFzgBXwye=ebPmEDN_6yqdKA6ZaD9hSUzbFjSacC_v3y5g@mail.gmail.com>
	<CA+55aFyvZAQbaEyq5atQbTjHTz_hodzhWKX_7SRL8nq+yBA14A@mail.gmail.com>
	<20130707.201449.1176672898198722699.davem@davemloft.net>
	<51DA5E65.5060006@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:54993 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751564Ab3GICrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jul 2013 22:47:52 -0400
In-Reply-To: <51DA5E65.5060006@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 08 Jul 2013 09:38:29 +0300 Eliezer Tamir <eliezer.tamir@linux.intel.com> wrote:

> On 08/07/2013 06:14, David Miller wrote:
> > From: Linus Torvalds <torvalds@linux-foundation.org>
> > Date: Sun, 7 Jul 2013 15:33:31 -0700
> >
> >> End result: I think the code is salvageable and people who want this
> >> kind of busy-looping can have it. But I really don't want to merge it
> >> as-is. I think it was badly done, I think it was badly documented, and
> >> I think somebody over-sold the feature by emphasizing the upsides and
> >> not the problems.
> >
> > Fair enough, Eliezer, please address all of Linus's feedback.
> >
> > It's holding the entire net-next merge up.
> >
> 
> OK

The feature should also be documented in the Linux manpages, please.  A
way to do that is to Cc linux-man@vger.kernel.org and Michael Kerrisk
<mtk.manpages@gmail.com>, and to work with Michael on developing that
documentation.
