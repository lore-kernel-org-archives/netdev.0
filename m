From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] [net-2.6.22] IrDA: irda lockdep annotation
Date: Fri, 16 Mar 2007 20:38:34 -0700 (PDT)
Message-ID: <20070316.203834.23011727.davem@davemloft.net>
References: <20070317015836.GC3429@sortiz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net,
	davej@redhat.com
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59270
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933965AbXCQDig (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 23:38:36 -0400
In-Reply-To: <20070317015836.GC3429@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samuel Ortiz <samuel@sortiz.org>
Date: Sat, 17 Mar 2007 03:58:36 +0200

> Rmmoding irda triggers a lockdep false positive.
> 
> Reported-by: Dave Jones <davej@redhat.com>
> Signed-off-by: Samuel Ortiz <samuel@sortiz.org>

Applied.
