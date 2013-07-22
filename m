From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] ip: initialize hash list
Date: Mon, 22 Jul 2013 08:06:56 -0700
Message-ID: <1374505616.2061.40.camel@joe-AO722>
References: <20130720102657.768a11ea@nehalam.linuxnetplumber.net>
	 <1374342380.1940.2.camel@joe-AO722>
	 <20130722075245.70310bfa@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Pravin B Shelar <pshelar@nicira.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:41681 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757084Ab3GVPG5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jul 2013 11:06:57 -0400
In-Reply-To: <20130722075245.70310bfa@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-07-22 at 07:52 -0700, Stephen Hemminger wrote:
> On Sat, 20 Jul 2013 10:46:20 -0700
> Joe Perches <joe@perches.com> wrote:
[]
> > Are you doing to do just this one or submit a series?
> 
> Hadn't planned on fixing more than one. And would not go outside code
> that I actually use.

What a pity.

I think if you identify what you believe is a
trivial defect in your own code, it's both
polite and social to fix similar defects in
other code too.
