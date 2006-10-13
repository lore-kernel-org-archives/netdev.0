From: David Miller <davem@davemloft.net>
Subject: Re: [IPv6] rules: Use RT6_LOOKUP_F_HAS_SADDR and fix source based
 selectors
Date: Thu, 12 Oct 2006 19:16:30 -0700 (PDT)
Message-ID: <20061012.191630.35017097.davem@davemloft.net>
References: <20061012094124.GH12964@postel.suug.ch>
	<20061012.185551.31808845.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	kim.nordlund@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:7332
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751488AbWJMCQ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Oct 2006 22:16:29 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20061012.185551.31808845.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 12 Oct 2006 18:55:51 +0900 (JST)

> I tend to agree.  Ville, do you agree?

I'll wait for Ville's response before applying this.
Otherwise, I think the change looks fine.
