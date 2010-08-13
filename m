From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] pcmcia: xirc2ps_cs bugfix
Date: Fri, 13 Aug 2010 16:48:52 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.1008131641230.17306@i5.linux-foundation.org>
References: <20100813185623.GC5853@comet.dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, Komuro <komurojun-mbn@nifty.com>
To: Dominik Brodowski <linux@dominikbrodowski.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:49293 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932077Ab0HMXtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Aug 2010 19:49:08 -0400
Received: by pwi4 with SMTP id 4so683736pwi.19
        for <netdev@vger.kernel.org>; Fri, 13 Aug 2010 16:49:08 -0700 (PDT)
In-Reply-To: <20100813185623.GC5853@comet.dominikbrodowski.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, 13 Aug 2010, Dominik Brodowski wrote:
> 
> could you apply the attached bugfix for PCMCIA, please? Alternatively,
> please pull from 
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/brodo/pcmcia-2.6.git master
> 
> where this one patch is located. What do you prefer, actually, if it is just
> one patch I want to push to you?

Doesn't really matter. These days, my workflow is so git-centric that a 
simple "git pull" is a tiny simpler just because it's what I do day in and 
day out, and doesn't involve exporting a patch and applying it - but the 
difference is really so small that it matters not at all. And applying the 
patch as a patch avoids a sily merge for a trivial change.

So it really can go both ways. I'll take the patch this time, because I 
happened to be in my "gather up patches" mode (which in turn is mostly 
because your subject said "PATCH" rather than "GIT PULL" - I had ignored 
the email while in my "git pull" phase). Which just goes to show how 
little I care, and how small details make me do one over the other.

So I think you should just base it on how convenient it is for you. 

But if you have even just two patches, I probably prefer a "git pull". 
But again, it's not a big deal.

                    Linus
