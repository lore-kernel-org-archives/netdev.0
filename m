From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH -tip 0/3] expedited "big hammer" RCU grace periods
Date: Wed, 24 Jun 2009 11:44:23 -0700
Message-ID: <20090624184423.GK6779@linux.vnet.ibm.com>
References: <20090624164535.GA13334@linux.vnet.ibm.com> <20090624180303.GE7576@elte.hu>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, davem@davemloft.net,
	dada1@cosmosbay.com, zbr@ioremap.net, jeff.chua.linux@gmail.com,
	paulus@samba.org, laijs@cn.fujitsu.com, jengelh@medozas.de,
	r000n@r000n.net, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:48291 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751631AbZFXSoX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jun 2009 14:44:23 -0400
Content-Disposition: inline
In-Reply-To: <20090624180303.GE7576@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 24, 2009 at 08:03:03PM +0200, Ingo Molnar wrote:
> 
> * Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> 
> >  include/linux/rcuclassic.h    |   15 ++-
> 
> heh, we dont have this file anymore ... as of today, right? :)

Ah, I was assuming that expedited RCU would happen before removal of
Classic RCU.

I will respin the expedited RCU patch.  ;-)

							Thanx, Paul
