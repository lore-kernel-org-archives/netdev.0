From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT]: Networking
Date: Sun, 31 Aug 2008 13:15:55 -0700 (PDT)
Message-ID: <alpine.LFD.1.10.0808311313260.12958@nehalem.linux-foundation.org>
References: <20080805.190020.244441681.davem@davemloft.net>  <alpine.LFD.1.10.0808051937410.15995@nehalem.linux-foundation.org>  <200808061021.56150.IvDoorn@gmail.com> <48B7CBA7.4060107@grupopie.com>
 <40f31dec0808311258q7598dfe3he81b7575375faff5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Rui Santos <rsantos@grupopie.com>,
	Ivo van Doorn <ivdoorn@gmail.com>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Nick Kossifidis <mickflemm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:34789 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756559AbYHaUQO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Aug 2008 16:16:14 -0400
In-Reply-To: <40f31dec0808311258q7598dfe3he81b7575375faff5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Sun, 31 Aug 2008, Nick Kossifidis wrote:
> 
> EeePC is working, the patch series i submitted adds support for RF2425
> chip which is included on EeePCs as far as i know (i have tested it on
> an EeePC 900 surf, i think EeePC 901 has the same card) ;-)

I think the EeePC 900 has a ath5k chip, and the 901/1000 has some totally 
different RaLink chip afaik.

I think the design change came when moving from Celeron to Atom.

		Linus
