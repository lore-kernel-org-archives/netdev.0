From: Ingo Molnar <mingo@elte.hu>
Subject: Re: tip: origin tree build failure, [patch] fix isdn/gigaset build
 failure
Date: Mon, 19 Apr 2010 23:01:42 +0200
Message-ID: <20100419210142.GA21440@elte.hu>
References: <20100419180520.GA9244@elte.hu>
 <alpine.LFD.2.00.1004191112550.14500@i5.linux-foundation.org>
 <alpine.LFD.2.00.1004191200050.14500@i5.linux-foundation.org>
 <20100419.120600.82034948.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, tilman@imap.cc,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100419.120600.82034948.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* David Miller <davem@davemloft.net> wrote:

> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Mon, 19 Apr 2010 12:00:49 -0700 (PDT)
> 
> > On Mon, 19 Apr 2010, Linus Torvalds wrote:
> >> 
> >> Maybe add the #include <linux/sched.h> into gigaset.h, instead of 
> >> common.c?
> > 
> > This compiled for me, although the only thing I tried was just turning all 
> > the gigaset options to 'y'. Maybe some other config doesn't work. So I 
> > committed it as likely to fix things.
> 
> Thanks Linus.
> 
> Ingo, let us know if there is still some problems in your
> build tests.

I did a few tests and it looks good here!

Thanks,

	Ingo
