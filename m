From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PATCH] NET: Fixes for net-2.6.19
Date: Thu, 28 Sep 2006 14:33:04 -0700 (PDT)
Message-ID: <20060928.143304.83622307.davem@davemloft.net>
References: <20060919.000800.127570535.yoshfuji@linux-ipv6.org>
	<20060927.224444.109879330.davem@davemloft.net>
	<20060928083645.786b1ab1@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, tgraf@suug.ch, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:54752
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964769AbWI1VdB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 17:33:01 -0400
To: shemminger@osdl.org
In-Reply-To: <20060928083645.786b1ab1@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Thu, 28 Sep 2006 08:36:45 -0700

> Please figure out how to keep rtnetlink.h useful from user space.
> I tried putting the current sanitized version of rtnetlink.h into
> iproute2 and the build fails. 

Please give the error so I have a chance of fixing this.
