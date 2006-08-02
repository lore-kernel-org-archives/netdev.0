From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Fix ___pskb_trim when entire frag_list needs dropping
Date: Wed, 02 Aug 2006 14:15:16 -0700 (PDT)
Message-ID: <20060802.141516.56862365.davem@davemloft.net>
References: <20060729114525.GA10549@gondor.apana.org.au>
	<BAY103-F18A6256BE13955FA46DA0DB2520@phx.gbl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:28064
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932191AbWHBVPG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Aug 2006 17:15:06 -0400
To: pupilla@hotmail.com
In-Reply-To: <BAY103-F18A6256BE13955FA46DA0DB2520@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Marco Berizzi" <pupilla@hotmail.com>
Date: Wed, 02 Aug 2006 17:01:17 +0200

> The problem is fixed now. I have applied this
> patch to 2.6.18-rc2
> Many thanks Herbert for all the time spent
> to debug this problem.

Thank you for testing.
