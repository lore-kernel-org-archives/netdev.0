From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Fri, 04 Dec 2015 15:06:33 -0500 (EST)
Message-ID: <20151204.150633.1744714566987717806.davem@davemloft.net>
References: <1449158374.11080.456996721.69F803D7@webmail.messagingengine.com>
	<CALx6S342OMLB6s7LcmnZP1rnYNUs345Dy1gjYX3JUKqqB_waPA@mail.gmail.com>
	<1449259145.6236.458303617.55CF2C4E@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, linville@tuxdriver.com, jesse@kernel.org,
	anjali.singhai@intel.com, netdev@vger.kernel.org,
	kiran.patil@intel.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42561 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753792AbbLDUGf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2015 15:06:35 -0500
In-Reply-To: <1449259145.6236.458303617.55CF2C4E@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 04 Dec 2015 20:59:05 +0100

> Yes, I agree, I am totally with you here. If generic offloading can be
> realized by NICs I am totally with you that this should be the way to
> go. I don't see that coming in the next (small number of) years, so I
> don't see a reason to stop this patchset.

If I just apply this and say "yeah ok", the message is completely lost
and your prediction about "small number of years" indeed will occur.

However if I push back hard on this, as I will, then the message has
some chance of seeping back to the people designing these chips.

So that's what I'm going to do, like it or not.

Or can someone convince me that someone who understand this stuff
is telling the hardware guys to universally put 2's complement
checksums into the descriptors?

Who is doing that at each and every prominent ethernet hardware
verndor?

Who?

If I get silence, or some vague non-specific response, then I'm going
to hold my ground and keep pushing back on this stuff.
