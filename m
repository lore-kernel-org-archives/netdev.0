From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] chelsio - Fix skb->dev setting
Date: Thu, 15 Nov 2007 15:06:42 -0800 (PST)
Message-ID: <20071115.150642.23394673.davem@davemloft.net>
References: <20071115113857.10170.87392.stgit@speedy5>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58431
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1764380AbXKOXGn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 18:06:43 -0500
In-Reply-To: <20071115113857.10170.87392.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>
Date: Thu, 15 Nov 2007 03:38:57 -0800

> From: Divy Le Ray <divy@chelsio.com>
> 
> eth_type_trans() now sets skb->dev. 
> Access skb->def after it gets set.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

Patch applied, thanks.
