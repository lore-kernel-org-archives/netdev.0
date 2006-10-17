From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/13] [IPV6] Remove struct pol_chain.
Date: Mon, 16 Oct 2006 22:07:50 -0700 (PDT)
Message-ID: <20061016.220750.77405487.davem@davemloft.net>
References: <45341BB3.6090907@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, tgraf@suug.ch, kim.nordlund@nokia.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:42129
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1423095AbWJQFHt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 01:07:49 -0400
To: vnuorval@tcs.hut.fi
In-Reply-To: <45341BB3.6090907@tcs.hut.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Date: Tue, 17 Oct 2006 02:54:27 +0300

> Struct pol_chain has existed since at least the 2.2 kernel, but isn't used
> anymore. As the IPv6 policy routing is implemented in a totally different
> way in the current kernel, just get rid of it.
> 
> Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>

That's obvious enough, good catch.

Applied, thanks a lot.
