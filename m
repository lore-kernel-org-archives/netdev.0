From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH v5 1/1 net] net: fec: fix kernel oops when plug/unplug
 cable many times
Date: Tue, 14 May 2013 23:42:17 -0300
Message-ID: <CAOMZO5CXUatKj0b=OuX_Cm5UiiuNbACG16Qnp9EY=_nMJ2g=bA@mail.gmail.com>
References: <1367971724-1974-1-git-send-email-Frank.Li@freescale.com>
	<20130513045710.GA4440@S2101-09.ap.freescale.net>
	<CAOMZO5AUk0GHKj857a0=Q-dxhpO2s7uatXurNVZV_UmEmtGsqQ@mail.gmail.com>
	<1368559834.4519.23.camel@edumazet-glaptop>
	<CAOMZO5DK6giehS9HpmXMzRKiDvvtEPLxvyenMQaBdrWS8WWVxw@mail.gmail.com>
	<CAHrpEqT=yD085tPPpvxG9heL1nHjZM0e7aHdA_2RdQrNWShRdw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Shawn Guo <shawn.guo@linaro.org>,
	Frank Li <Frank.Li@freescale.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Robert Schwebel <r.schwebel@pengutronix.de>,
	David Miller <davem@davemloft.net>,
	Lucas Stach <l.stach@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Frank Li <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:54782 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752001Ab3EOCmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 May 2013 22:42:18 -0400
Received: by mail-pd0-f170.google.com with SMTP id 10so948424pdi.15
        for <netdev@vger.kernel.org>; Tue, 14 May 2013 19:42:18 -0700 (PDT)
In-Reply-To: <CAHrpEqT=yD085tPPpvxG9heL1nHjZM0e7aHdA_2RdQrNWShRdw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 14, 2013 at 10:56 PM, Frank Li <lznuaa@gmail.com> wrote:

> I also find the same solution yesterdays. I tested on MX6. Shawn
> tested on MX6 and MX28.
> You can submit patch.

Thanks, Frank. Will submit it tomorrow.
