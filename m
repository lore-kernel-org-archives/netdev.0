From: David Miller <davem@davemloft.net>
Subject: Re: [IPv6] rules: Use RT6_LOOKUP_F_HAS_SADDR and fix source based
 selectors
Date: Fri, 13 Oct 2006 15:01:26 -0700 (PDT)
Message-ID: <20061013.150126.126576193.davem@davemloft.net>
References: <20061012.185551.31808845.yoshfuji@linux-ipv6.org>
	<20061012.191630.35017097.davem@davemloft.net>
	<452F5544.6080407@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, tgraf@suug.ch, netdev@vger.kernel.org,
	kim.nordlund@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:56481
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932081AbWJMWB0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Oct 2006 18:01:26 -0400
To: vnuorval@tcs.hut.fi
In-Reply-To: <452F5544.6080407@tcs.hut.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Date: Fri, 13 Oct 2006 11:58:44 +0300

> Acked-by: Ville Nuorvala <vnuorval@tcs.hut.fi>

Thanks, I've applied Thomas's patch.

> I'm currently working on a patch for all of this, but please go ahead
> and apply Thomas's and Kim's patch.
> 
> I'll try to post an initial RFC version of my patch later today.

Sounds great.
