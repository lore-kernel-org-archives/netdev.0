From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH net-next 1/1] Microchip's LAN7800 family USB 2/3 to
 10/100/1000 Ethernet device driver
Date: Fri, 31 Jul 2015 22:26:02 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D539861@CHN-SV-EXMX02.mchp-main.com>
References: <9235D6609DB808459E95D78E17F2E43D538C9D@CHN-SV-EXMX02.mchp-main.com>
 <20150731.151915.1788101742098740589.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp03.microchip.com ([198.175.253.49]:64604 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753222AbbGaW0E convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 18:26:04 -0400
In-Reply-To: <20150731.151915.1788101742098740589.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for all reviews & comments.

- Woojung

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Friday, July 31, 2015 6:19 PM
> To: Woojung Huh - C21699
> Cc: netdev@vger.kernel.org
> Subject: Re: [PATCH net-next 1/1] Microchip's LAN7800 family USB 2/3 to
> 10/100/1000 Ethernet device driver
> 
> From: <Woojung.Huh@microchip.com>
> Date: Thu, 30 Jul 2015 19:45:21 +0000
> 
> > Repost patch of driver for LAN7800 family of USB 2.0 & USB 3.0 to Gigabit E=
> > thernet.
> > - remove module param which can be configurable by standard mechanism.
> > - remove other module parms except msg_level per review comment.
> > - update to handle byte swap for statistics structure correctly.
> >
> > Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
> 
> Applied, thanks.
