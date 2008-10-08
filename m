From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] add a sysctl to disable TCP simultaneous connection opening
Date: Wed, 8 Oct 2008 20:24:13 +0200
Message-ID: <20081008182413.GA1813@1wt.eu>
References: <20081008081109.GA25342@1wt.eu> <20081008.094212.130684373.davem@davemloft.net> <20081008170739.GA546@1wt.eu> <20081008.112133.226941794.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:4673 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754778AbYJHSYS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 14:24:18 -0400
Content-Disposition: inline
In-Reply-To: <20081008.112133.226941794.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 08, 2008 at 11:21:33AM -0700, David Miller wrote:
> From: Willy Tarreau <w@1wt.eu>
> Date: Wed, 8 Oct 2008 19:07:39 +0200
> 
> > On Wed, Oct 08, 2008 at 09:42:12AM -0700, David Miller wrote:
> > > and that's a good argument to not apply "yet another random knob"
> > > to the kernel.
> > 
> > OK for the random knob. If you feel comfortable with a patch to simply remove
> > the feature, I can send you such a patch too.
> 
> If I don't want the knob, what makes you think I'll accept a patch to
> remove or ifdef the code?
> 
> I absolutely will not.

OK at least now it's clear.

Thanks anyway,
Willy

