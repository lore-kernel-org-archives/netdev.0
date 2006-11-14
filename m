From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/6] IPv6: Fix infinite loop if no matching IPv6 tunnel
 found
Date: Mon, 13 Nov 2006 16:57:16 -0800 (PST)
Message-ID: <20061113.165716.26277561.davem@davemloft.net>
References: <4549EFA7.50004@tcs.hut.fi>
	<20061102.231810.119656005.yoshfuji@linux-ipv6.org>
	<4549FF0F.6020705@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:28834
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S933280AbWKNA5I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Nov 2006 19:57:08 -0500
To: vnuorval@tcs.hut.fi
In-Reply-To: <4549FF0F.6020705@tcs.hut.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Date: Thu, 02 Nov 2006 16:22:07 +0200

> Ok, I'll resubmit a patch doesn't send an ICMPv6 error message.

Is this coming soon?  I'd like to integrate this patch set into
net-2.6.20 if I can.
