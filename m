From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tulip : fix 21142 with 10Mbps without negotiation
Date: Fri, 30 Jan 2009 13:49:16 -0800 (PST)
Message-ID: <20090130.134916.39232340.davem@davemloft.net>
References: <20090127165727.GA25748@frolo.macqel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: phdm@macqel.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35385
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753984AbZA3VtT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 16:49:19 -0500
In-Reply-To: <20090127165727.GA25748@frolo.macqel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe De Muyter <phdm@macqel.be>
Date: Tue, 27 Jan 2009 17:57:27 +0100

> with current kernels, tulip 21142 ethernet controllers fail to connect
> to a 10Mbps only (i.e. without negotiation-partner) network.  It used
> to work in 2.4 kernels.  Fix that.  Tested on a 21142 Rev 0x11.
> 
> Signed-off-by: Philippe De Muyter <phdm@macqel.be>

Applied, thanks Philippe.
