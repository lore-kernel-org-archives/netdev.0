From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] sungem: Spring cleaning and GRO support
Date: Thu, 02 Jun 2011 14:14:30 -0700 (PDT)
Message-ID: <20110602.141430.1224168098779433370.davem@davemloft.net>
References: <1306912630.29297.34.camel@pasglop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ruediger.herbst@googlemail.com,
	bhamilton04@gmail.com
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44311 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752922Ab1FBVOe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 17:14:34 -0400
In-Reply-To: <1306912630.29297.34.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 01 Jun 2011 17:17:10 +1000

> It still needs testing on sparc and maybe a bit more torturing on
> powerpc. I've done some cursory link up/down tests on a g5 and a
> powerbook g4 here, and some suspend/resume tests, so far with
> success, but I'll do more tomorrow just in case.

I'll give this a quick spin on one of my sparc64 boxes that has
a sungem in it.  If all goes well I'll just apply this to net-next-2.6

Thanks!
