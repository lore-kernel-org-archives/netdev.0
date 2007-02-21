From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address Detection
Date: Wed, 21 Feb 2007 08:37:13 -0500
Message-ID: <20070221133713.GA3504@hmsreliant.homelinux.net>
References: <20070221.040259.60395625.yoshfuji@linux-ipv6.org> <20070221.000222.71087924.davem@davemloft.net> <20070221.171545.35764627.yoshfuji@linux-ipv6.org> <20070221.013031.48806156.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yoshfuji@linux-ipv6.org, vladislav.yasevich@hp.com, sri@us.ibm.com,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3491 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161238AbXBUNmQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Feb 2007 08:42:16 -0500
Content-Disposition: inline
In-Reply-To: <20070221.013031.48806156.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 21, 2007 at 01:30:31AM -0800, David Miller wrote:
> From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Date: Wed, 21 Feb 2007 17:15:45 +0900 (JST)
> 
> > In article <20070221.000222.71087924.davem@davemloft.net> (at Wed, 21 Feb 2007 00:02:22 -0800 (PST)), David Miller <davem@davemloft.net> says:
> > 
> > > > So, I think it is ready. Here's my sign-off:
> > > > 
> > > > Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> > > 
> > > Neil, please keep this patch ready for the next merge window.
> > 
> > Dave, Neil,
> > 
> > I expect to have some changes in routing code in near future,
> > I want to have Neil's change in my -dev tree, if you don't mind.
> 
> I have no problem with this, and I am sure Neil will be OK
> with it too.

Absolutely, I'll keep my devel branch rebased against Daves tree until its all
checked in, just in case any updates are needed.

Thanks for all the help everyone!
Neil

