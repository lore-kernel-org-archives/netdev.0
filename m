From: "Robert P. J. Day" <rpjday@mindspring.com>
Subject: {Spam?} Re: {Spam?} [PATCH] NET: Remove obsolete traffic shaper code.
Date: Sat, 14 Apr 2007 20:06:26 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0704141959190.22316@localhost.localdomain>
References: <Pine.LNX.4.64.0704141925310.22138@localhost.localdomain>
 <5640c7e00704141646k44334de9g99dc509bf96bac5f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Ian McDonald <ian.mcdonald@jandi.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nic.NetDirect.CA ([216.16.235.2]:54381 "EHLO
	rubicon.netdirect.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962AbXDOAHt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Apr 2007 20:07:49 -0400
In-Reply-To: <5640c7e00704141646k44334de9g99dc509bf96bac5f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


(i'm betting that the mail server i use back in canada is going to tag
this yet again with "{Spam?}" since i'm in california at the moment
and i'll just bet it's freaking out seeing stuff coming from a totally
unknown IP address.  i've already sent an email to the admins about
this.  sorry.)

On Sun, 15 Apr 2007, Ian McDonald wrote:

> On 4/15/07, Robert P. J. Day <rpjday@mindspring.com> wrote:
> >
> > Remove the obsolete code for the traffic shaper.
> >
> > Signed-off-by: Robert P. J. Day <rpjday@mindspring.com>
> >
> Apart from the merits of removing this which I can't comment on, I
> thought the usual procedure was to place a removal in
> Documentation/feature-removal-schedule.txt to notify people of what
> is going to be removed. Then wait the period you determine there and
> then remove.

in fact, according to this:

http://lkml.org/lkml/2006/1/13/139

that notice was put in the feature removal file well over a year ago,
during 2.6.15.  so that would seem to be more than adequate time for
everyone to prepare for it.  but it must have been deleted from that
file since then as well.

i probably should have mentioned that in my initial posting.

rday
-- 
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://fsdev.net/wiki/index.php?title=Main_Page
========================================================================
