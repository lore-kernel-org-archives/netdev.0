From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 v3] mv643xx_eth: use sw csum for big packets
Date: Wed, 30 Jun 2010 13:01:36 -0700 (PDT)
Message-ID: <20100630.130136.135969405.davem@davemloft.net>
References: <1277634403-1018-1-git-send-email-saeed@marvell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: saeed@marvell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35272
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751530Ab0F3UBZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 16:01:25 -0400
In-Reply-To: <1277634403-1018-1-git-send-email-saeed@marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Bishara <saeed@marvell.com>
Date: Sun, 27 Jun 2010 13:26:43 +0300

> Some controllers (KW, Dove) limits the TX IP/layer4 checksum offloading to a max size.
> 
> Signed-off-by: Saeed Bishara <saeed@marvell.com>
> Acked-by: Lennert Buytenhek <buytenh@wantstofly.org>

Applied to net-2.6, thanks.
