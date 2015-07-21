From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4] ipv6: sysctl to restrict candidate source
 addresses
Date: Tue, 21 Jul 2015 16:06:07 -0700 (PDT)
Message-ID: <20150721.160607.1437575878451357084.davem@davemloft.net>
References: <1437401083-32696-1-git-send-email-ek@google.com>
	<CAAedzxpEoyMEAyOW--+5jjjx59aS=mAHS_8TNB3HaxvqQr8jyQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com, hannes@stressinduktion.org,
	lorenzo@google.com, netdev@vger.kernel.org
To: ek@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34476 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415AbbGUXGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 19:06:07 -0400
In-Reply-To: <CAAedzxpEoyMEAyOW--+5jjjx59aS=mAHS_8TNB3HaxvqQr8jyQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Kline <ek@google.com>
Date: Mon, 20 Jul 2015 16:06:34 +0200

> I thought perhaps "use_oif_addr_only" was a slightly clearer sysctl name.
> 
> (Maybe it should be plural, "use_oif_addrs_only"?)

I think plural would be better too, please respin with that change.

Thanks.
