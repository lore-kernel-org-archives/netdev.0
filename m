From: Marek Vasut <marex@denx.de>
Subject: Re: [PATCH V3 5/5] net: can: ifi: Add IFI CANFD IP support
Date: Wed, 20 Jan 2016 16:40:27 +0100
Message-ID: <201601201640.27809.marex@denx.de>
References: <569F944A.4090201@pengutronix.de> <201601201603.40080.marex@denx.de> <569FA33C.5060805@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Oliver Hartkopp <socketcan@hartkopp.net>,
	Mark Rutland <mark.rutland@arm.com>,
	Wolfgang Grandegger <wg@grandegger.com>
To: "Marc Kleine-Budde" <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:45078 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751367AbcATPk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 10:40:29 -0500
In-Reply-To: <569FA33C.5060805@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, January 20, 2016 at 04:09:48 PM, Marc Kleine-Budde wrote:
> On 01/20/2016 04:03 PM, Marek Vasut wrote:
> >> Doh! Right, let's try this:
> >>>> -#define IFI_CANFD_INTERRUPT_ERROR_WARNING      BIT(1)
> >>>> +#define IFI_CANFD_INTERRUPT_ERROR_WARNING      ((u32)BIT(1))
> >>> 
> >>> I'd be happy to be proven wrong though.
> >> 
> >> /me too
> > 
> > I think that will do the trick too. Do you want a V4 patch or will you
> > fix it?
> 
> I'll fix this.

Thanks :)

Best regards,
Marek Vasut
