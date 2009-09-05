From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] net: Add DEVTYPE support for Ethernet based devices
Date: Sat, 05 Sep 2009 06:34:00 +0200
Message-ID: <1252125240.27694.5.camel@violet>
References: <1251788899-30156-1-git-send-email-marcel@holtmann.org>
	 <1252109846.27694.1.camel@violet>
	 <20090904.202750.249172306.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	johannes@sipsolutions.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:47416 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750751AbZIEEeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Sep 2009 00:34:00 -0400
In-Reply-To: <20090904.202750.249172306.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

> > can you please give me some feedback on this patch.
> 
> Johannes recommended using a NETDEV_REGISTER hook, I'm
> waiting for you to try and use that instead of this
> patch.

that was for the Wireless drivers part. Total different from what this
patch trying to achieve.

> Your patch is ugly, so I'd like to avoid it if possible.

What is ugly about it. Do you have any other recommendation on how let
userspace know what type of Ethernet device it is?

Regards

Marcel


