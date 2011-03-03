From: David Miller <davem@davemloft.net>
Subject: bonding...
Date: Wed, 02 Mar 2011 21:49:10 -0800 (PST)
Message-ID: <20110302.214910.112578818.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41836
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754570Ab1CCFsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 00:48:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hey, if someone could step up and help with bonding maintainence
in some tangible way, I'd really appreciate it.

Currently the situation is that many people work on bonding patches,
and whilst I do try and wait for some ACKs to arrive, I am the person
who has to sort out when changes are ready, decide to apply them, and
poke for review when things fall through the cracks.

Sometimes patches go for weeks without ACKs, and in that situation
I have to either try to understand the changes myself, or wait
potentially forever for someone with bonding knowledge to take a
good look at the patch and properly review it.

It was nearly 2 weeks before Oleg V. Ukhno's 802.3ad round-robin patch
got looked at by anyone with bonding knowledge.  And it only happened
because I got tired of seeing his poor patch rot in patchwork
and had to explicitly asked for review the other day.

This is unacceptable, people are submitting multiple bonding patches
every single day now.  It needs a clueful bonding person looking at
these submissions on a constant basis.

This is a serious problem and is backlogging the netdev patch queue.

So if someone would become an active bonding patch-accumulator, and
send me sets of patches that are ready to apply, I would really
appreciate it.

Thanks.
