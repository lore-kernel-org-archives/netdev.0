From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH 1/1] net/fec: add KSZ9021RN phy fixup
Date: Tue, 13 Dec 2011 10:36:27 +0800
Message-ID: <20111213023626.GA10866@S2100-06.ap.freescale.net>
References: <1323684558-16796-1-git-send-email-richard.zhao@linaro.org>
 <CAOMZO5DNRrt7ULuBkh9y8bz2_fpCHOcSWxAbJOqTHA2Nrv1V_w@mail.gmail.com>
 <20111212135119.GE16835@b20223-02.ap.freescale.net>
 <4EE612BF.9050907@bluegiga.com>
 <20111213021008.GE28768@b20223-02.ap.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Veli-Pekka Peltola <veli-pekka.peltola@bluegiga.com>,
	<s.hauer@pengutronix.de>, <shawn.guo@linaro.org>,
	Fabio Estevam <festevam@gmail.com>, <patches@linaro.org>,
	<netdev@vger.kernel.org>, <jgq516@gmail.com>,
	<eric.miao@linaro.org>, <davem@davemloft.net>,
	Richard Zhao <richard.zhao@linaro.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Richard Zhao <richard.zhao@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe001.messaging.microsoft.com ([216.32.181.181]:26498
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751106Ab1LMCXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 21:23:33 -0500
Content-Disposition: inline
In-Reply-To: <20111213021008.GE28768@b20223-02.ap.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 13, 2011 at 10:10:08AM +0800, Richard Zhao wrote:
> By converting to DT, machine code's becoming common too. I feel hard to
> find a place. Put it in imx6q_init_machine?
> 
> Sascha & Shawn, Could you give comments here?
> 
I see no problem to do that by checking board compatible string and
do the setup for particular board.

-- 
Regards,
Shawn
