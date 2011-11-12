From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: vlan: 802.1ad S-VLAN support
Date: Sat, 12 Nov 2011 17:22:18 -0500 (EST)
Message-ID: <20111112.172218.203118257266590280.davem@davemloft.net>
References: <1320512055-1231037-2-git-send-email-equinox@diac24.net>
	<20111111.202235.1981500713669985784.davem@davemloft.net>
	<20111112141429.GA41984@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, mirqus@gmail.com
To: equinox@diac24.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35815 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220Ab1KLWZG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Nov 2011 17:25:06 -0500
In-Reply-To: <20111112141429.GA41984@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lamparter <equinox@diac24.net>
Date: Sat, 12 Nov 2011 15:14:29 +0100

> Well, hmm... Suggestions?

The feature is important to you, therefore you're the one who needs
to figure out how to avoid the memory bloat.

And no, config options aren't how to do this, every distribution
(and therefore %99 of users) will have it enabled.
