From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] sky2: fix limited auto negotiation
Date: Sun, 09 Jan 2011 15:53:35 -0800 (PST)
Message-ID: <20110109.155335.27810695.davem@davemloft.net>
References: <AANLkTimGZbDNeRccp4SkgOsJsLXjyKNq+ma4UvW=-5GG@mail.gmail.com>
	<20110106204036.1e45e982@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: m.hariri@gmail.com, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54960
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752774Ab1AIXxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jan 2011 18:53:04 -0500
In-Reply-To: <20110106204036.1e45e982@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Thu, 6 Jan 2011 20:40:36 -0800

> The sky2 driver would always try all possible supported speeds even
> if the user only asked for a limited set of speed/duplex combinations.
> 
> Reported-by: Mohsen Hariri <m.hariri@gmail.com>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
