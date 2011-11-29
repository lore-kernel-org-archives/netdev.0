From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] dsa: Move switch drivers to new directory
 drivers/net/dsa
Date: Tue, 29 Nov 2011 01:20:30 -0500 (EST)
Message-ID: <20111129.012030.2292326438418729327.davem@davemloft.net>
References: <1322449506.7454.34.camel@deadeye>
	<1322449713.7454.36.camel@deadeye>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34919 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751694Ab1K2GUi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 01:20:38 -0500
In-Reply-To: <1322449713.7454.36.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Mon, 28 Nov 2011 03:08:33 +0000

> Support for specific hardware belongs under drivers/net/ not net/.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Applied.
