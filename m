From: Duan Fugang-B38611 <B38611@freescale.com>
Subject: RE: [PATCH] net: fec: fix phy reset operation to let imx6sl evk work
Date: Tue, 10 Sep 2013 08:21:18 +0000
Message-ID: <9848F2DB572E5649BA045B288BE08FBE016A95E0@039-SN2MPN1-023.039d.mgd.msft.net>
References: <1378780505-23102-1-git-send-email-B38611@freescale.com>
 <20130910081434.GG5815@S2101-09.ap.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	Li Frank-B20596 <B20596@freescale.com>,
	"s.hauer@pengutronix.de" <s.hauer@pengutronix.de>
To: Shawn Guo <shawn.guo@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe004.messaging.microsoft.com ([65.55.88.14]:51726 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753107Ab3IJIVX convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Sep 2013 04:21:23 -0400
In-Reply-To: <20130910081434.GG5815@S2101-09.ap.freescale.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shawn Guo [mailto:shawn.guo@linaro.org]
Data: Tuesday, September 10, 2013 4:15 PM

> To: Duan Fugang-B38611
> Cc: davem@davemloft.net; netdev@vger.kernel.org; bhutchings@solarflare.com;
> stephen@networkplumber.org; Li Frank-B20596; s.hauer@pengutronix.de
> Subject: Re: [PATCH] net: fec: fix phy reset operation to let imx6sl evk
> work
> 
> First of all, the patch does not apply on linux-next which means it will
> likely not apply on David's tree either.  Please generate the patch
> against the tree which your patch will go through.
> 
Sorry, pls drop to review the patch, there have two changes in local (Linux-next) not commit amend to the patch.
But I tested the patch (+ changes) on imx6sl evk and pass.

I send the integrated patch again.
