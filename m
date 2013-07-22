From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ip: initialize hash list
Date: Mon, 22 Jul 2013 08:15:58 -0700
Message-ID: <1374506158.4990.11.camel@edumazet-glaptop>
References: <20130720102657.768a11ea@nehalam.linuxnetplumber.net>
	 <1374342380.1940.2.camel@joe-AO722>
	 <20130722075245.70310bfa@nehalam.linuxnetplumber.net>
	 <1374505616.2061.40.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:40586 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755213Ab3GVPQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 11:16:04 -0400
Received: by mail-pa0-f54.google.com with SMTP id kx10so7188635pab.41
        for <netdev@vger.kernel.org>; Mon, 22 Jul 2013 08:16:03 -0700 (PDT)
In-Reply-To: <1374505616.2061.40.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-07-22 at 08:06 -0700, Joe Perches wrote:
> On Mon, 2013-07-22 at 07:52 -0700, Stephen Hemminger wrote:
> > On Sat, 20 Jul 2013 10:46:20 -0700
> > Joe Perches <joe@perches.com> wrote:
> []
> > > Are you doing to do just this one or submit a series?
> > 
> > Hadn't planned on fixing more than one. And would not go outside code
> > that I actually use.
> 
> What a pity.
> 
> I think if you identify what you believe is a
> trivial defect in your own code, it's both
> polite and social to fix similar defects in
> other code too.

Joe, I find this quite misplaced.

So far, there is no bug.

What about fixing real bugs instead ?
