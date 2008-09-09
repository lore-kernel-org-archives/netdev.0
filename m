From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: EEH recovery fix
Date: Tue, 09 Sep 2008 02:59:24 -0700 (PDT)
Message-ID: <20080909.025924.49180949.davem@davemloft.net>
References: <BD3F7F1EFBA6D54DB056C4FFA45140080334A46036@SJEXCHCCR01.corp.ad.broadcom.com>
	<20080908.124743.30466861.davem@davemloft.net>
	<1220952889.15079.3.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yitchak.gertner@broadcom.com
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56805
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751412AbYIIJ7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 05:59:32 -0400
In-Reply-To: <1220952889.15079.3.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Tue, 09 Sep 2008 12:34:49 +0300

> IBM found it on PPC and it was more obvious with the DMA mapping
> violation. It is broken in the same way on 2.6.26 as well.
 ...
> If you cannot accept it into 2.6.27, I will re-send it into net-next.
> Please let me know.

Given what you've said I think net-next is the way to go, please
submit it for there.

Thanks.
