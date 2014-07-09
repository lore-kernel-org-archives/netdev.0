From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] arc_emac: Remove unused pointer to net_device from
 arc_emac_priv
Date: Wed, 09 Jul 2014 16:49:43 -0700 (PDT)
Message-ID: <20140709.164943.797934251131977857.davem@davemloft.net>
References: <1404896876-29315-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34657 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751294AbaGIXto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2014 19:49:44 -0400
In-Reply-To: <1404896876-29315-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Wed,  9 Jul 2014 11:07:56 +0200

> The pointer to the struct net_device in the private data is only
> assigned but never used, so delete it.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Also applied, thank you.
