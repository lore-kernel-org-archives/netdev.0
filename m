From: Greg Ungerer <gerg@snapgear.com>
Subject: Re: FEC Patches
Date: Wed, 28 Jan 2009 17:37:21 +1000
Message-ID: <49800B31.9020608@snapgear.com>
References: <1233052804-31228-1-git-send-email-s.hauer@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, frederic rodo <fred.rodo@gmail.com>
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.securecomputing.com ([203.24.151.4]:40670 "EHLO
	cyberguard.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752171AbZA1HhW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 02:37:22 -0500
In-Reply-To: <1233052804-31228-1-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sascha,

Sascha Hauer wrote:
> Sorry guys, sending this again. Of course I'm not 'y', just playing
> git-send-email:
> 
> Who should the emails appear to be from? [Sascha Hauer <s.hauer@pengutronix.de>] y[es]
> Emails will be sent from: y
> 
> 
> These patches are an updated version from the ones I posted some time ago.
> They give the FEC ethernet driver a facelift and turn it into a
> platform_device driver. The Coldfire cores are still supported through
> legacy ifdefs. The platform driver support has been tested on a
> Freescale i.MX27 SoC.

Outside of the one patch I commented on the series applies, runs and
seems to work OK on the ColdFire parts I tried it on.

Thanks
Greg


------------------------------------------------------------------------
Greg Ungerer  --  Principal Engineer        EMAIL:     gerg@snapgear.com
SnapGear, a McAfee Company                  PHONE:       +61 7 3435 2888
825 Stanley St,                             FAX:         +61 7 3891 3630
Woolloongabba, QLD, 4102, Australia         WEB: http://www.SnapGear.com
