From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ksz884x: fix return value of netdev_set_eeprom
Date: Tue, 23 Mar 2010 13:09:42 -0700 (PDT)
Message-ID: <20100323.130942.09762502.davem@davemloft.net>
References: <4BA8CEF6.2010707@LiPPERTEmbedded.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Tristram.Ha@micrel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: JRottmann@LiPPERTEmbedded.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50274
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753613Ab0CWUJT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 16:09:19 -0400
In-Reply-To: <4BA8CEF6.2010707@LiPPERTEmbedded.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jens Rottmann <JRottmann@LiPPERTEmbedded.de>
Date: Tue, 23 Mar 2010 15:23:50 +0100

> ksz884x: fix return value of netdev_set_eeprom
> 
> netdev_set_eeprom() confused ethtool by just returning 1 on error
> instead of a proper -EINVAL.
> 
> Signed-off-by: Jens Rottmann <JRottmann@LiPPERTEmbedded.de>

Applied, thank you.
