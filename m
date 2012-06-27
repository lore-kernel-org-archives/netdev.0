From: hayeswang <hayeswang@realtek.com>
Subject: RE: Unknown chipsets from Realtek's 8168 driver
Date: Wed, 27 Jun 2012 10:43:03 +0800
Message-ID: <A8D0CF5460074425A9047CB50C94617D@realtek.com.tw>
References: <20120626102635.GB1854@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: 'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:45152 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754295Ab2F0CnM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 22:43:12 -0400
In-Reply-To: <20120626102635.GB1854@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Francois Romieu [mailto:romieu@fr.zoreil.com] 
> 
>   there appears to remain unknown chipsets in Realtek's own driver.
> Namely:
> - CFG_METHOD_21
> - CFG_METHOD_22

I am adding the two now. However, there are many differences for them, so I have
to think how to do.

> - CFG_METHOD_23

The settings for this one are not final yet. Please skip it.
> 
> Should support for some of those be added to the kernel driver ?
> 
> If so it would make sense to plan for those now as there are still a
> couple of weeks ahead before the window for -next closes and 
> everything
> experiences more than 2 months of delay. You will find some incomplete
> stuff below. Feel free to use or ignore it.

Thanks. I would complete it as soon as possible.

 
Best Regards,
Hayes
