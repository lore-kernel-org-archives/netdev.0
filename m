From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 3/4] caif: Use link layer MTU instead of
 fixed MTU
Date: Sun, 20 Jun 2010 20:39:00 -0700 (PDT)
Message-ID: <20100620.203900.229729770.davem@davemloft.net>
References: <1276793741-20278-1-git-send-email-sjur.brandeland@stericsson.com>
	<1276793741-20278-2-git-send-email-sjur.brandeland@stericsson.com>
	<1276793741-20278-3-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sjurbr@gmail.com, netdev@vger.kernel.org,
	linus.walleij@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46941
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757210Ab0FUDis (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jun 2010 23:38:48 -0400
In-Reply-To: <1276793741-20278-3-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sjur.brandeland@stericsson.com
Date: Thu, 17 Jun 2010 18:55:40 +0200

> From: Sjur Braendeland <sjur.brandeland@stericsson.com>
> 
> Previously CAIF supported maximum transfer size of ~4050.
> The transfer size is now calculated dynamically based on the
> link layers mtu size.
> 
> Signed-off-by: Sjur Braendeland@stericsson.com

Applied.
