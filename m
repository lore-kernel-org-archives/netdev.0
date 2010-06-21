From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 2/4] caif: Bugfix - RFM must support
 segmentation.
Date: Sun, 20 Jun 2010 20:38:52 -0700 (PDT)
Message-ID: <20100620.203852.232767644.davem@davemloft.net>
References: <1276793741-20278-1-git-send-email-sjur.brandeland@stericsson.com>
	<1276793741-20278-2-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sjurbr@gmail.com, netdev@vger.kernel.org,
	linus.walleij@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46936
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757210Ab0FUDij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jun 2010 23:38:39 -0400
In-Reply-To: <1276793741-20278-2-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sjur.brandeland@stericsson.com
Date: Thu, 17 Jun 2010 18:55:39 +0200

> From: Sjur Braendeland <sjur.brandeland@stericsson.com>
> 
> CAIF Remote File Manager may send or receive more than 4050 bytes.
> Due to this The CAIF RFM service have to support segmentation.
> 
> Signed-off-by: Sjur Braendeland@stericsson.com

Applied.
