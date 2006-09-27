From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan support for pktgen
Date: Wed, 27 Sep 2006 16:30:59 -0700 (PDT)
Message-ID: <20060927.163059.102771174.davem@davemloft.net>
References: <7c923b5e0609131017i4a04512rab45cff32e09527e@mail.gmail.com>
	<17689.13463.736977.366105@robur.slu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: francesco.fondelli@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:17577
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965166AbWI0XbA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 19:31:00 -0400
To: Robert.Olsson@data.slu.se
In-Reply-To: <17689.13463.736977.366105@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robert Olsson <Robert.Olsson@data.slu.se>
Date: Tue, 26 Sep 2006 16:09:27 +0200

> 
> Francesco Fondelli writes:
> 
>  > The attached patch allows pktgen to produce 802.1Q and Q-in-Q tagged frames.
>  > I have used it for stress test a bridge and seems ok to me.
>  > Unfortunately I have no access to net-2.6.x git tree so the diff is against
>  > 2.6.17.13.
> 
> Thanks a lot.
> 
> Looks fine but haven't been able to test Q-in-Q. Below is a git diff.
> We ask Dave to apply.

Applied, thanks Robert.
