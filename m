From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm4: strip ECN bits from tos field
Date: Wed, 22 Sep 2010 20:26:13 -0700 (PDT)
Message-ID: <20100922.202613.258117509.davem@davemloft.net>
References: <20100922164511.GA10963@babylon>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: uweber@astaro.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56444
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751662Ab0IWDZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 23:25:54 -0400
In-Reply-To: <20100922164511.GA10963@babylon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ulrich Weber <uweber@astaro.com>
Date: Wed, 22 Sep 2010 18:45:11 +0200

> otherwise ECT(1) bit will get interpreted as RTO_ONLINK
> and routing will fail with XfrmOutBundleGenError.
> 
> Signed-off-by: Ulrich Weber <uweber@astaro.com>

Applied, thanks a lot.
