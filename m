From: David Miller <davem@davemloft.net>
Subject: Re: crash in ipt_do_table
Date: Thu, 17 Aug 2006 22:58:30 -0700 (PDT)
Message-ID: <20060817.225830.63127321.davem@davemloft.net>
References: <44E1D3A2.3020604@trash.net>
	<20060817.181403.78708132.davem@davemloft.net>
	<44E55417.2000508@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chris@ex-parrot.com, akpm@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:49107
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964843AbWHRF6S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 01:58:18 -0400
To: kaber@trash.net
In-Reply-To: <44E55417.2000508@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 18 Aug 2006 07:45:59 +0200

> Thanks, but it seems you applied the first patch I sent, which was
> missing the same fix for arp_tables. This patch contains the missing
> bits.
> 
> I'm going to send the (combined) patch to -stable as well, this bug
> seems to have hit quite a few people.

I just sent a round of patches to Greg for his 2.6.18 tree, which
included the first part, so I'll push this second part to him next.

Feel free to queue the whole thing up for -stable, thanks a lot.
