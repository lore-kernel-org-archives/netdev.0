From: David Miller <davem@davemloft.net>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison
 overwritten
Date: Thu, 17 Jul 2008 15:09:01 -0700 (PDT)
Message-ID: <20080717.150901.02086760.davem@davemloft.net>
References: <20080717214222.GA29449@elte.hu>
	<20080717.144504.96425101.davem@davemloft.net>
	<20080717220600.GA1701@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	penberg@cs.helsinki.fi, vegard.nossum@gmail.com, rjw@sisk.pl
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47187
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754475AbYGQWJB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 18:09:01 -0400
In-Reply-To: <20080717220600.GA1701@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Fri, 18 Jul 2008 00:06:00 +0200

> > > Perhaps SLUB debugging got smarter?
> 
> and Cc:-ed SLUB folks. Could be a sleeper cell of bugs gone active ;-) 

This bug would be a quite positive result then :)
