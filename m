From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 002/002] de2104x: support for systems lacking cache
 coherence
Date: Wed, 11 Feb 2009 13:39:55 -0800 (PST)
Message-ID: <20090211.133955.60089579.davem@davemloft.net>
References: <20090210.152143.176850113.davem@davemloft.net>
	<46e1c7760902110418n276de9b2xa2169839b9e25dc0@mail.gmail.com>
	<46e1c7760902110431p54c0b5f7oa1a07726f4db5021@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, netdev@vger.kernel.org
To: risto.suominen@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57635
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750950AbZBKVkC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2009 16:40:02 -0500
In-Reply-To: <46e1c7760902110431p54c0b5f7oa1a07726f4db5021@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Risto Suominen <risto.suominen@gmail.com>
Date: Wed, 11 Feb 2009 14:31:43 +0200

> As an interesting side effect, the patch caused my mesh module to stop
> working. It crashes.

I think you need to take this discussion to linuxppc-dev at this
point.

Nobody amongst the networking developers can say whether
your NOT_COHERENT_CACHE change is a valid or desirable
way to solve the problem, nor what side effects it might
have.
