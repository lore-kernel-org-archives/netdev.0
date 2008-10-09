From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/8 2.6.28] cxgb3 - commnonize LASI phy code
Date: Wed, 08 Oct 2008 17:42:39 -0700 (PDT)
Message-ID: <20081008.174239.55460197.davem@davemloft.net>
References: <20081009003424.13446.70530.stgit@speedy5>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59329
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757911AbYJIAnE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 20:43:04 -0400
In-Reply-To: <20081009003424.13446.70530.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>
Date: Wed, 08 Oct 2008 17:34:24 -0700

> Add generic code to manage interrupt driven PHYs.
> Do not reset the phy after link parameters update,
> the new values might get lost.
> Return early from link change notification
> when the link parameters remain unchanged.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

Applied.
