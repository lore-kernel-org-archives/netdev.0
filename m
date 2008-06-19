From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 11/15]bnx2x: Add TPA, Broadcoms HW LRO
Date: Thu, 19 Jun 2008 14:50:35 -0700 (PDT)
Message-ID: <20080619.145035.69303095.davem@davemloft.net>
References: <20080617151704.GK5350@solarflare.com>
	<20080617.161640.256235010.davem@davemloft.net>
	<1213897363.19376.1.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	mchan@broadcom.com, vladz@broadcom.com
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34862
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751598AbYFSVuf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 17:50:35 -0400
In-Reply-To: <1213897363.19376.1.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Thu, 19 Jun 2008 20:42:43 +0300

> Just to make sure that we are working in the right direction: we will
> add the ethtool support and the gso_size, but until Ben's patch will be
> in place, we will still fail in the same way any other LRO driver will
> fail in forwarding.

Basically, yes.
