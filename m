From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/7] [IrDA] af_irda: irda_accept cleanup
Date: Fri, 20 Apr 2007 22:09:45 -0700 (PDT)
Message-ID: <20070420.220945.27646002.davem@davemloft.net>
References: <20070418213202.214829666@sortiz.org>
	<20070418214750.826786570@sortiz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net,
	olaf.kirch@oracle.com
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55784
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754470AbXDUFJm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Apr 2007 01:09:42 -0400
In-Reply-To: <20070418214750.826786570@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: samuel@sortiz.org
Date: Thu, 19 Apr 2007 00:32:05 +0300

> This patch removes a cut'n'paste copy of wait_event_interruptible
> from irda_accept.
> 
> Signed-off-by: Samuel Ortiz <samuel@ortiz.org>
> Acked-by: Olaf Kirch <olaf.kirch@oracle.com>

Applied to net-2.6.22, thanks.
