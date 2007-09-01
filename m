From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [beck@bofh.cns.ualberta.ca: I respect the GPL immensely,
	really I do - but I believe this type of action weakens us all.]
Date: Sun, 2 Sep 2007 01:49:52 +0200
Message-ID: <20070901234952.GA16016@stusta.de>
References: <20070901224112.GC24887@bofh.cns.ualberta.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Bob Beck <beck@bofh.cns.ualberta.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:50750 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932230AbXIAXtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Sep 2007 19:49:51 -0400
Content-Disposition: inline
In-Reply-To: <20070901224112.GC24887@bofh.cns.ualberta.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 01, 2007 at 04:41:12PM -0600, Bob Beck wrote:
> ----- Forwarded message from Bob Beck <beck@bofh.cns.ualberta.ca> -----
> 
> From: Bob Beck <beck@bofh.cns.ualberta.ca>
> To: misc@openbsd.org
> Subject: I respect the GPL immensely, really I do - but I believe this type of action weakens us all.
> X-Spam-Checker-Version: SpamAssassin 3.1.8 (2007-02-13) on bofh.cns.ualberta.ca
> X-Spam-Level: 
> X-Spam-Status: No, score=-2.8 required=3.0 tests=AWL,BAYES_00,
> 	DNS_FROM_RFC_ABUSE,FORGED_RCVD_HELO autolearn=no version=3.1.8
> Date: Sat, 1 Sep 2007 16:22:43 -0600
> User-Agent: Mutt/1.5.12-2006-07-14
> 
>  [ A copy of this is going to the linux kernel mailing list, regarding the
> recent license modifications to reyk's files]
> 
> >Oh, and if you look at the OpenBSD CVS you see versions 4 months old 
> >with dozens of contributions by Reyk and with:
> >
> >/*      $OpenBSD: ath.c,v 1.63 2007/05/09 16:41:14 reyk Exp $  */
> >/*      $NetBSD: ath.c,v 1.37 2004/08/18 21:59:39 dyoung Exp $        */
> >/*-
> > * Copyright (c) 2002-2004 Sam Leffler, Errno Consulting
> > * All rights reserved.
> 
>    Of course you do! because some of reyk's work used some of Sam's
> work, and unlike what it seems a portion of the Linux community seems
> to be willing to do in their Zealotry for the GPL, reyk is not
> *removing and modifying* the licenses granted by the original authors.
> That's the point. He's not saying he wrote this piece, and he's not
> *changing* the conditions under which Sam distributed the code in the
> first place. However what scares me more is the seeming willingness to
> make the authors of a derivative work appear to be the primary authors
> of something, and a willingness to change an authors copyright
> statement (on reyk's code) without his permission. 
>...

You miss the whole point of dual licencing:

Sam has stated in the licence that the code can be distributed under the 
terms of the BSD licence, or alternatively it can be distributed under 
the terms of the GPLv2.

Noone removed Sam's licence.

Sam has offered a choice, and if you choose one of the two offered 
licences when distributing his code that complies with what he stated
in his copyright notice.

IANAL, but if reyk contributed to dual licenced code keeping the file 
dual licenced it's hard to argue that he did not make the changes he 
made available dual licenced.

>    I seriously hope that saner more mature and forward thinking heads
> inside the Linux community will stop bashing the things that Theo and
> the rest of our community is saying just because it's coming from
> Theo, and he's a great target to bash, and start thinking about what
> you are doing to free software as a whole. I think you are on the
> verge of doing irreparable damage that will seriously weaken the
> ability for all of our projects to move forward, and protect our
> rights as code authors in the future.

The funny thing is that it seems Jiri's patch contained copyright 
violations - and the parts of his patch Theo attacks are the parts
that are OK...

> 	-Bob

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

