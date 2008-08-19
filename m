From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [GIT]: Networking
Date: Tue, 19 Aug 2008 20:27:31 +0200
Message-ID: <1219170451.7591.175.camel@violet.holtmann.net>
References: <20080819.041706.261399060.davem@davemloft.net>
	 <alpine.LFD.1.10.0808190952000.3324@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:35532 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751014AbYHSS13 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 14:27:29 -0400
In-Reply-To: <alpine.LFD.1.10.0808190952000.3324@nehalem.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Linus,

> For example, those BT updates looked in no way like regression fixes.

the Bluetooth fixes do fix one regression that broke user space
assumptions.

I included additional support for one new driver since I was under the
assumption that new driver support is fine since it can't introduce a
regression. If that has changed then please spell this out and we have
to apply this rule to all subsystems.

Also I cleaned up the MAINTAINERS file entries for Bluetooth. Are these
considered harmful now and should be postponed to the next merge window?
They can obviously not introduce any regressions?

Regards

Marcel


