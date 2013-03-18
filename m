From: Shawn Guo <shawn.guo@linaro.org>
Subject: Re: [RFC 0/3] arm: mxs: sanitize enet_out clock handling
Date: Mon, 18 Mar 2013 14:40:24 +0800
Message-ID: <20130318064021.GA4713@S2101-09.ap.freescale.net>
References: <1359470773-14290-1-git-send-email-w.sang@pengutronix.de>
 <CA+7tXiinVCjs7NAdGd+0KyUL+kfwWUi_XAPYdMHiugT3W2Xz4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wolfram Sang <w.sang@pengutronix.de>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	Shawn Guo <shawn.guo@freescale.com>
To: Trent Piepho <tpiepho@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe002.messaging.microsoft.com ([216.32.181.182]:5913
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750813Ab3CRGkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 02:40:24 -0400
Content-Disposition: inline
In-Reply-To: <CA+7tXiinVCjs7NAdGd+0KyUL+kfwWUi_XAPYdMHiugT3W2Xz4w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 15, 2013 at 02:27:35PM -0700, Trent Piepho wrote:
> But as you say most boards need enet_out (AFAICT, all but the Denx
> board).  So wouldn't it make more sense to add enet_out to the dtsi
> file and then just override it in the one board that doesn't need it,
> instead of overriding in every board except that one?

Yes, sounds reasonable.  Since I'm not sure Wolfram is still interested
in the work, I will pick it up from here.

Shawn
