From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] ipv6: fix ICMP6_MIB_OUTERRORS
Date: Wed, 09 Jun 2010 18:39:41 -0700 (PDT)
Message-ID: <20100609.183941.102556904.davem@davemloft.net>
References: <1275985484.2475.59.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58576
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755921Ab0FJBjb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 21:39:31 -0400
In-Reply-To: <1275985484.2475.59.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 08 Jun 2010 10:24:44 +0200

> In commit 1f8438a85366 (icmp: Account for ICMP out errors), I did a typo
> on IPV6 side, using ICMP6_MIB_OUTMSGS instead of ICMP6_MIB_OUTERRORS
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
