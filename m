From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bcm63xx_enet: Use ARRAY_SIZE instead of open coding it
Date: Thu, 24 Apr 2014 13:39:21 -0400 (EDT)
Message-ID: <20140424.133921.441330350218015644.davem@davemloft.net>
References: <1398274970-8882-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33005 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757450AbaDXRjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 13:39:23 -0400
In-Reply-To: <1398274970-8882-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Wed, 23 Apr 2014 19:42:50 +0200

> Use the ARRAY_SIZE macro to determine the number of entries in
> bcm_enet_gstrings_stats.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied to net-next, thanks Tobias.
