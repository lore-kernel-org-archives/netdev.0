From: David Miller <davem@davemloft.net>
Subject: Re: DF Bit set on UDP traffic -- bug or feature?
Date: Wed, 19 Aug 2009 21:16:31 -0700 (PDT)
Message-ID: <20090819.211631.197791532.davem@davemloft.net>
References: <4A8C8945.70602@gdt.id.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gdt@gdt.id.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60547
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750787AbZHTEQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 00:16:19 -0400
In-Reply-To: <4A8C8945.70602@gdt.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Glen Turner <gdt@gdt.id.au>
Date: Thu, 20 Aug 2009 09:22:45 +1000

> Can I humbly suggest that when the kernel does not implement
> its own fragmentation strategy (as it does with TCP Path MTU
> Discovery) that the DF bit not be set by the kernel?

It's UDP path MTU discovery, it's legal, and Linux has been
doing it for almost 10 years.

I don't think it's changing, sorry.

