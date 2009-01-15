From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PULL -tip] fixed few make headers_check warnings
Date: Thu, 15 Jan 2009 15:51:26 +0100
Message-ID: <20090115145126.GA1702@elte.hu>
References: <Pine.LNX.4.64.0901140954250.27308@anakin> <3f9a31f40901140129i1389f47frf32808f3a695a118@mail.gmail.com> <20090114153825.GB32082@uranus.ravnborg.org> <3f9a31f40901140759s1542e6cclae1808b796c2b1a9@mail.gmail.com> <Pine.LNX.4.64.0901141732450.26663@anakin> <20090114201513.GC1556@uranus.ravnborg.org> <20090115111134.GB22850@elte.hu> <20090115143717.GA11991@uranus.ravnborg.org> <3f9a31f40901150647n7ef5b2dfuf5c588f584c2a472@mail.gmail.com> <20090115145046.GB872@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sam Ravnborg <sam@ravnborg.org>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Jaswinder Singh Rajput <jaswinder@infradead.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	x86 maintainers <x86@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Jaswinder Singh Rajput <jaswinderlinux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:53104 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759695AbZAOOvy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2009 09:51:54 -0500
Content-Disposition: inline
In-Reply-To: <20090115145046.GB872@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Ingo Molnar <mingo@elte.hu> wrote:

> 
> * Jaswinder Singh Rajput <jaswinderlinux@gmail.com> wrote:
> 
> > Hello Sam,
> > 
> > On Thu, Jan 15, 2009 at 8:07 PM, Sam Ravnborg <sam@ravnborg.org> wrote:
> > >
> > > I can disable the warnings around -rc7 if we think they are too noisy 
> > > when we release the next kernel.
> > 
> > I will like to question the approach how you get this number '-rc7'
> > 
> > Do you think people can bear this noise till -rc7 or they will solve all 
> > these warnings before -rc7
> 
> the noise is not bearable, it hides a lot of real bugs. We should do the 
> fixes you posted and get them to Linus.

btw., could you please put them into your Git tree and post a pull 
request, so that i can check how many warnings there are left?

	Ingo
