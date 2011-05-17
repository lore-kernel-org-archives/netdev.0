From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv1 (Repost)] bnx2x: Allow ethtool to enable/disable
 loopback.
Date: Mon, 16 May 2011 21:42:35 -0400 (EDT)
Message-ID: <20110516.214235.666307082194750944.davem@davemloft.net>
References: <1304472033-510-1-git-send-email-maheshb@google.com>
	<1305335329-32700-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org, therbert@google.com
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44228 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751862Ab1EQBmn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 21:42:43 -0400
In-Reply-To: <1305335329-32700-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Fri, 13 May 2011 18:08:49 -0700

> This patch updates the bnx2x_set_features() to handle loopback mode.
> When enabled; it sets internal-MAC loopback.
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

I forgot to mention that I've applied this to net-next-2.6, thanks.
