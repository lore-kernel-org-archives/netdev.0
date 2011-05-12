From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv6 2/2] tg3: Allow ethtool to enable/disable loopback.
Date: Thu, 12 May 2011 15:04:48 -0700 (PDT)
Message-ID: <20110512.150448.104060641.davem@davemloft.net>
References: <1304749117-1989-1-git-send-email-maheshb@google.com>
	<1304873508-24307-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, netdev@vger.kernel.org, mchan@broadcom.com,
	therbert@google.com
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37083
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758736Ab1ELWFU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 18:05:20 -0400
In-Reply-To: <1304873508-24307-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Sun,  8 May 2011 09:51:48 -0700

> This patch adds tg3_set_features() to handle loopback mode. Currently the
> capability is added for the devices which support internal MAC loopback mode.
> So when enabled, it enables internal-MAC loopback.
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

Applied, thanks.
