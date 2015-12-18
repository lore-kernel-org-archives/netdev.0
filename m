From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] nfp: call netif_carrier_off() during init
Date: Fri, 18 Dec 2015 15:31:48 -0500 (EST)
Message-ID: <20151218.153148.310614347822860478.davem@davemloft.net>
References: <1450361924-25223-1-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, simon.horman@netronome.com,
	rolf.neugebauer@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44794 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964980AbbLRUbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 15:31:52 -0500
In-Reply-To: <1450361924-25223-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Thu, 17 Dec 2015 14:18:44 +0000

> Netdevs default to carrier on, we should call netif_carrier_off()
> during initialization since we handle carrier state changes in the
> driver.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Rolf Neugebauer <rolf.neugebauer@netronome.com>

Applied, thanks.
