From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] [net-2.6.22] IrDA: removing stir4200 useless
 include
Date: Fri, 16 Mar 2007 20:35:45 -0700 (PDT)
Message-ID: <20070316.203545.112852129.davem@davemloft.net>
References: <20070317015802.GB3429@sortiz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@vger.kernel.org
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58760
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933964AbXCQDfq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 23:35:46 -0400
In-Reply-To: <20070317015802.GB3429@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samuel Ortiz <samuel@sortiz.org>
Date: Sat, 17 Mar 2007 03:58:02 +0200

> stir4200 doesn't need to include irlap.h
> 
> Signed-off-by: Samuel Ortiz <samuel@sortiz.org>

Applied, thanks.
