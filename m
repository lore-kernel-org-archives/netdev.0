From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] ipv4: Early TCP socket demux.
Date: Tue, 19 Jun 2012 11:31:37 -0700
Message-ID: <20120619113137.44d80c27@s6510.linuxnetplumber.net>
References: <20120618.194016.2282814982594761206.davem@davemloft.net>
	<a22edf13-1bf5-49fb-8ebe-05054f68c129@tahiti.vyatta.com>
	<CABa6K_E+EzeJQF_m4aoq1WAYUwWQxd8_=k7HT0XZ6P5EpBR+4g@mail.gmail.com>
	<20120618.211613.921381844240194486.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, stephen.hemminger@vyatta.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36921 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753075Ab2FSSbk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 14:31:40 -0400
In-Reply-To: <20120618.211613.921381844240194486.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 18 Jun 2012 21:16:13 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Changli Gao <xiaosuo@gmail.com>
> Date: Tue, 19 Jun 2012 12:13:48 +0800
> 
> > On Tue, Jun 19, 2012 at 12:03 PM, Stephen Hemminger
> > <stephen.hemminger@vyatta.com> wrote:
> >>
> >>>
> >>> You know you want it.
> >>>
> >>> Signed-off-by: David S. Miller <davem@davemloft.net>
> >>
> >> David, I understand it, Eric understands it, and maybe one or
> >> two others. But on the principal of what is "good for the goose
> >> is good for the gander", you really need to provide a reasonable
> >> change log entry. Just because you are the network maintainer
> >> doesn't mean you get to skip all the documented rules about submitting
> >> patches.
> > 
> > Agree. Thanks.
> 
> That's the last time I try to be even slightly humerous on this
> list.
> 
> Thanks for killing the fun Stephen.

We all need to lighten up, keep trying to be humorous.
Maybe you just need better material. The IP stack is just in too good
a shape, how about something with more natural whackiness like bluetooth.
