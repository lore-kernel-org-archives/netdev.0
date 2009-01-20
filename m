From: David Miller <davem@davemloft.net>
Subject: Re: wimax/i2400m: error paths that need to free an skb should use
 kfree_skb()
Date: Mon, 19 Jan 2009 17:26:00 -0800 (PST)
Message-ID: <20090119.172600.261205226.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: inaky@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51027
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755705AbZATBZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 20:25:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Applied, thanks.
