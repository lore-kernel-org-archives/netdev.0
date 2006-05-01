From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 2/6] tg3: Add phy workaround
Date: Sun, 30 Apr 2006 21:45:47 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC041BBED@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:30737 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S1750790AbWEAEqA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 May 2006 00:46:00 -0400
Content-class: urn:content-classes:message
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

> From: "Michael Chan" <mchan@broadcom.com>
> Date: Fri, 28 Apr 2006 16:35:19 -0700
> 
> > Add some PHY workaround code to reduce jitter on some PHYs.
> > 
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
> 
> Applied, thanks.
> 
> It really bugs me that all of this indirect addressing into
> the DSP is done with magic addresses and register values.  It
> would be great to get some defined in tg3.h that documented
> the DSP register set properly.
> 
Ok, will add some constants next time.

