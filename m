From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: netconsole still hangs
Date: Thu, 13 Mar 2008 00:25:35 -0700
Message-ID: <20080313002535.9cc7b946.akpm@linux-foundation.org>
References: <20080312165717.c0879b1d.akpm@linux-foundation.org>
	<20080312.231053.216645957.davem@davemloft.net>
	<20080312235205.dcec2d35.akpm@linux-foundation.org>
	<20080313.001255.01742148.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	rjw@sisk.pl
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59868 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750783AbYCMHZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2008 03:25:41 -0400
In-Reply-To: <20080313.001255.01742148.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 13 Mar 2008 00:12:55 -0700 (PDT) David Miller <davem@davemloft.net> wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Wed, 12 Mar 2008 23:52:05 -0700
> 
> > Whine.  I can _trivially_ reproduce this stuff on the two machines which I
> > tried it on.  Has anyone over in net land actually expended some cycles
> > trying to reproduce these things?
> 
> I would if I weren't in Japan currently giving presentations
> and attending BoF's, so whining at me isn't very productive.

Others were cc'ed..

> I asked you to do the bisect check since that's the fastest
> way forward at the current time.

I'm sitting here waiting to do it, but was hoping that you'd
know what the magical git command is.
