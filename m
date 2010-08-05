From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: remove noisy and hardly useful printk
Date: Thu, 05 Aug 2010 13:21:49 -0700 (PDT)
Message-ID: <20100805.132149.71592467.davem@davemloft.net>
References: <1280996076-19708-1-git-send-email-christian.samsel@rwth-aachen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dhollis@davehollis.com
To: christian.samsel@rwth-aachen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47417
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932979Ab0HEUVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 16:21:30 -0400
In-Reply-To: <1280996076-19708-1-git-send-email-christian.samsel@rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Samsel <christian.samsel@rwth-aachen.de>
Date: Thu, 05 Aug 2010 10:14:36 +0200

> With turned on hspa modem (Dell 5530 internal card) and activated usb auto
> suspend, my system gets up 100 "usbnet_resume has delayed data" per
> minute. I didnt noticed any pathological behaviour, so just drop
> this message. if any objections, please at least change it to _DEBUG.
> 
> Signed-off-by: Christian Samsel <christian.samsel@rwth-aachen.de>

I agree, and I'll apply this, thanks.
