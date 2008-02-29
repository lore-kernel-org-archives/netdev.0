From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [IPV6]: Add ORCHID prefix to address label table
Date: Thu, 28 Feb 2008 20:55:11 -0800 (PST)
Message-ID: <20080228.205511.09236600.davem@davemloft.net>
References: <20080221100813.GA24291@verkkotelakka.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jmtapio@verkkotelakka.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46193
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754565AbYB2EzM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2008 23:55:12 -0500
In-Reply-To: <20080221100813.GA24291@verkkotelakka.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Juha-Matti Tapio <jmtapio@verkkotelakka.net>
Date: Thu, 21 Feb 2008 12:08:14 +0200

> Add a new label for Overlay Routable Cryptographic Hash Identifiers
> (RFC 4843) prefix 2001:10::/28 to help proper source address
> selection.
> 
> ORCHID addresses are used by for example Host Identity Protocol. They are 
> global and routable, but they currently need support from both endpoints 
> and therefore mixing regular and ORCHID addresses for source and 
> destination is a bad idea in general case.
> 
> Signed-off-by: Juha-Matti Tapio <jmtapio@verkkotelakka.net>

Applied to net-2.6.26, thanks.
