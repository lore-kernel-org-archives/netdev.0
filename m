From: Diego Viola <diego.viola@gmail.com>
Subject: Re: [PATCH] jme: remove the jme driver as it is no longer maintained
Date: Sat, 20 Feb 2016 22:33:19 -0200
Message-ID: <CA+ToGPEZoe3tnJQHNYED1bxSGrcdZP+AyQHjv==pMovwqYniig@mail.gmail.com>
References: <1456003203-10863-1-git-send-email-diego.viola@gmail.com>
	<20160220.191659.1399118945067159430.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	cooldavid@cooldavid.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160220.191659.1399118945067159430.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 20, 2016 at 10:16 PM, David Miller <davem@davemloft.net> wrote:
>
> Sorry, this is not how things work.
>
> You can suggest marking the driver unmaintained in MAINTAINERS if the
> listed developer has been unresponsive for a very long time.
>
> But removing the driver altogether is not prudent at all.
>
> Just because it doesn't work %100 the way you like, and nobody
> has worked on fixing your specific problems, isn't a reason to
> remove an entire driver _nor_ move it to -staging.
>
> In fact, this driver is quite cleanly written, follows all of the
> various coding style rules we have, and uses the vast majority of the
> kernel APIs properly.
>
> And those are the criteria for having something in staging, not that
> it has bugs.
>
> In fact it is so cleanly written, that you should be able to read it
> and figure out what the suspend/resume problem might be.  These are
> exactly the kind of drivers we want to keep in the tree.
>
> I'm sorry that your bugs didn't get fixed, but your response to that
> happening is not reasonable at all.

OK my sincere apologies.

I've been very frustrated trying to deal with this bug and I couldn't
find a solution yet, but I will continue to see what I can do to fix
it.

I would appreciate some hint from someone who is more experienced with drivers.

Anyways, sorry about my behavior.

Diego
