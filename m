From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: tun routing is broken
Date: Mon, 7 Mar 2011 13:54:18 +0100 (CET)
Message-ID: <alpine.LRH.2.00.1103071352100.19033@twin.jikos.cz>
References: <20110304.010603.104076956.davem@davemloft.net> <4D70B2DC.2000005@gmail.com> <4D71EE86.6030309@suse.cz> <20110305.001022.183044112.davem@davemloft.net> <4D71F194.9010402@suse.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Jiri Slaby <jirislaby@gmail.com>, linux-kernel@vger.kernel.org,
	mm-commits@vger.kernel.org, netdev@vger.kernel.org,
	maxk@qualcomm.com
To: Jiri Slaby <jslaby@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:53612 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751088Ab1CGMyb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 07:54:31 -0500
In-Reply-To: <4D71F194.9010402@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 5 Mar 2011, Jiri Slaby wrote:

> > Date: Sat, 05 Mar 2011 09:04:22 +0100
> > 
> >> Ok, so I booted the new kernel, and tun is broken there completely. If I
> >> try to ping a vpn peer:
> > 
> > -mm tree is missing this fix which went in yesterday.  Please if
> > you are going to be testing networking a lot, test against net-next-2.6
> > instead of Andrew's tree which invariable lags behind:
> 
> I'm not testing networking, I'm just using my desktop :). (And
> next/master is mostly unusable for these needs. In comparison to mmotm
> which is some kind of a "release".)

I have been hit by similar issues several times already as well.

I guess that question of including -mm into linux-next should be raised 
again here ... Andrew, if I remember correctly, on last kernel summit you 
were stating that you'd stop eating untill you have -mm included in -next. 
Seems like you must be quite hungry these days already :)

Thanks,

-- 
Jiri Kosina
SUSE Labs, Novell Inc.

