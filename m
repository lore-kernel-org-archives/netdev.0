From: Maciej Rutecki <maciej.rutecki@gmail.com>
Subject: Regression tracking [WAS: Re: recvmsg sleeping from invalid context]
Date: Sun, 22 Jan 2012 20:52:02 +0100
Message-ID: <201201222052.02135.maciej.rutecki@gmail.com>
References: <201201220854.59968.maciej.rutecki@gmail.com> <201201222031.51116.maciej.rutecki@gmail.com> <20120122.143728.1710688129934394279.davem@davemloft.net>
Reply-To: maciej.rutecki@gmail.com
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, rjw@sisk.pl
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:54561 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752196Ab2AVTwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2012 14:52:09 -0500
In-Reply-To: <20120122.143728.1710688129934394279.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On niedziela, 22 stycznia 2012 o 20:37:28 David Miller wrote:
> From: Maciej Rutecki <maciej.rutecki@gmail.com>
> Date: Sun, 22 Jan 2012 20:31:51 +0100
> 
> > These entries are using for tracking regressions, for *all* kernel parts,
> > without any exception. I see no reason to treat someone differently. If
> > netdev provides any interface to tracking regressions, then show me it.
> > But then why you do not use one common tool for all kernel?
> 
> This mailing list is the tracking mechanism.
> 
> You can create whatever you want, but I can guarentee that the very
> people who can actually move the bug forward and fix the problem will
> look at it.
> 
> It's been like this for ages, Andrew Morton understands how we wish
> to track bugs, and that we don't want to use bugzilla for that purpose.

OK. But tracking regressions in two (or more) places is nonsense. And this 
puts into question all of my current work, such as how to analyze 
(automatically) the progress of the whole kernel and its quality per each -rc. 
Problem to discussion, but if everyone will do as you wish, it will all work 
went to waste.

I do not say that resolving regression in mailinglist is bad. I think that is 
as good as bug tracker. Bug entry is helps us store information in one places. 
E.g. "Refernces" tag redirect people to discussion in LKML. But I say again: I 
think that LKML is not regression tracker, but helps solve regression.
 
Regards
-- 
Maciej Rutecki
http://www.mrutecki.pl
