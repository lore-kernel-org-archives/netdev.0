From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RESEND][PATCH] ebtables: clean up vmalloc usage in
 net/bridge/netfilter/ebtables.c
Date: Wed, 19 Apr 2006 15:59:25 -0700
Message-ID: <20060419155925.7aae7d25.akpm@osdl.org>
References: <20060419065025.GE17192@random.pao.digeo.com>
	<20060419.154126.64036253.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jchandra@digeo.com, bridge@osdl.org, bdschuym@pandora.be,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:14796 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751312AbWDSW5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2006 18:57:09 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060419.154126.64036253.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"David S. Miller" <davem@davemloft.net> wrote:
>
> An earlier variant of your patch was applied already, included below.
> You'll need to submit the newer parts relative to the current tree.

This is a similar-but-different patch.  It applies OK.

I reviewed it (mostly - it's somewhat non-trivial to do this) and queued it
up and was planning on sending it to you for post-2.6.17.
