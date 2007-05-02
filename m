From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/20][BNX2]: Bug fixes and more 5709 suppot.
Date: Wed, 02 May 2007 00:14:08 -0700 (PDT)
Message-ID: <20070502.001408.35689862.davem@davemloft.net>
References: <1178068303.4820.35.camel@dell>
	<4638394D.7020005@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57626
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S2992874AbXEBHOJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 03:14:09 -0400
In-Reply-To: <4638394D.7020005@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Wed, 02 May 2007 03:10:05 -0400

> NAK.  Multiple patches for a single changes means you broke git bisect.
> 
> The 5709 firmware update should be in a single changeset (thus, single 
> patch).

Mailing list limitations aren't even an excuse for this one
any more as the limit is ~400K now :-)
