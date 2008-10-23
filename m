From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] sctp: rfc conformance fixes
Date: Thu, 23 Oct 2008 17:15:16 +1100
Message-ID: <20081023061514.GA14658@verge.net.au>
References: <20081022.164636.143240158.davem@davemloft.net> <20081022.164834.08272239.davem@davemloft.net> <48FFD25F.8090807@hp.com> <20081022.210649.06597758.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vladislav.yasevich@hp.com, jk@ozlabs.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:51722 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751254AbYJWGPS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2008 02:15:18 -0400
Content-Disposition: inline
In-Reply-To: <20081022.210649.06597758.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 22, 2008 at 09:06:49PM -0700, David Miller wrote:
> From: Vlad Yasevich <vladislav.yasevich@hp.com>
> Date: Wed, 22 Oct 2008 21:24:47 -0400
> 
> > David Miller wrote:
> > > From: David Miller <davem@davemloft.net>
> > > Date: Wed, 22 Oct 2008 16:46:36 -0700 (PDT)
> > > 
> > >> From: Jeremy Kerr <jk@ozlabs.org>
> > >> Date: Thu, 23 Oct 2008 09:54:02 +1100
> > >>
> > >>>> Oddly enough, none of this series made it to patchwork.
> > >>> I'll chase this up then - could you formward a copy of one of the 
> > >>> messages after it has come through the list?
> > >> Here is one of them.
> > > 
> > > Sorry, I'm a bozo, that was a copy that made it privately to me.
> > > 
> > > I don't have any copies in my inbox that came via vger.
> > > 
> > 
> > Really?  They made it to vger and back out.  They are also in
> > the archive or marc.   I wonder which black hole some of them
> > disappeared to... :)
> 
> I meant that I didn't save any such copies.
> 
> When I read my email I always get 2, 3, 4 copies of every damn
> patch, so I delete all but one of those and I happened to save only
> the instances that were directly sent to me this time.  It's just
> random what happens.

For what it is worth, I use the following procmail rule to elimintate
duplicate messages based on Message-Id.

	PROCMAIL_ROOT=${HOME}/.procmail

        :0
	* ? /usr/bin/formail -D 819200 ${PROCMAIL_ROOT}/log/message.cache
	/dev/null

-- 
Simon Horman
  VA Linux Systems Japan K.K., Sydney, Australia Satellite Office
  H: www.vergenet.net/~horms/             W: www.valinux.co.jp/en

