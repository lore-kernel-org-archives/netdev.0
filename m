From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Subject: Re: pull request: wireless-next-2.6 2009-10-28
Date: Thu, 29 Oct 2009 18:49:23 +0100
Message-ID: <200910291849.23526.bzolnier@gmail.com>
References: <200910291435.54203.bzolnier@gmail.com> <200910291514.40318.bzolnier@gmail.com> <20091029.072101.109209962.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: penberg@cs.helsinki.fi, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linville@tuxdriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.189]:45104 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753013AbZJ2RwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 13:52:04 -0400
In-Reply-To: <20091029.072101.109209962.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 29 October 2009 15:21:01 David Miller wrote:
> From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
> Date: Thu, 29 Oct 2009 15:14:40 +0100
> 
> > Dave, if you have problems with executing the command locally I'll be
> > happy to supply you with the patch.
> 
> This is not the issue.
> 
> The issue is that John disagrees with you can you can't handle
> that.
> 
> So instead of continuing to discuss things with him and the
> other wireless folks, you want me to just overreach everybody
> and revert someone else's work.

Lets look at the technical merits of this work.

It is 5 KLOC of dead code and it should be 1-2 KLOC of working code
(we may turn the blink eye on "working" part but FFS at least fix other
parts)..

Hey, Linus.  We have a new driver for ya.  It doesn't work, has design
problems and is not even half-finished but most wireless folks are fine
with it!

I wonder when things went so wrong here..

> I'm not going to do that sorry, learn how to work with the
> wireless people instead.

This is a waste of time since technical merit doesn't find much love there.

Sorry Dave but you're making me go over your head now and go into unpleasant
mode again..

Looking on how you just reverted cmd64x change which you were so proud while
taking IDE over shows where the real problem is -- in subsystems supervised
by you loyalty and rank is everything while you are busy playing the pointy
haired boss everywhere from arm to ide.

--
Bartlomiej Zolnierkiewicz
