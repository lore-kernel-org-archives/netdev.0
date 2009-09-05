From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Add DEVTYPE support for Ethernet based devices
Date: Fri, 04 Sep 2009 20:27:50 -0700 (PDT)
Message-ID: <20090904.202750.249172306.davem@davemloft.net>
References: <1251788899-30156-1-git-send-email-marcel@holtmann.org>
	<1252109846.27694.1.camel@violet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	johannes@sipsolutions.net
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34499
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934146AbZIED1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2009 23:27:36 -0400
In-Reply-To: <1252109846.27694.1.camel@violet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Sat, 05 Sep 2009 02:17:26 +0200

> can you please give me some feedback on this patch.

Johannes recommended using a NETDEV_REGISTER hook, I'm
waiting for you to try and use that instead of this
patch.

Your patch is ugly, so I'd like to avoid it if possible.
