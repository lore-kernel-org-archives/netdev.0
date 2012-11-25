From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 8139cp: re-enable interrupts after tx timeout
Date: Sun, 25 Nov 2012 15:57:00 -0500 (EST)
Message-ID: <20121125.155700.212888701428484557.davem@davemloft.net>
References: <20121124213348.GA8313@electric-eye.fr.zoreil.com>
	<1353795081.26346.287.camel@shinybook.infradead.org>
	<20121124225855.GA17340@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dwmw2@infradead.org, netdev@vger.kernel.org, jasowang@redhat.com,
	gilboad@gmail.com, jgarzik@redhat.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40612 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751530Ab2KYU5K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Nov 2012 15:57:10 -0500
In-Reply-To: <20121124225855.GA17340@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Sat, 24 Nov 2012 23:58:55 +0100

> David Woodhouse <dwmw2@infradead.org> :
>> Recovery doesn't work too well if we leave interrupts disabled...
>> 
>> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
> 
> Acked-by: Francois Romieu <romieu@fr.zoreil.com>

Applied to net-next
