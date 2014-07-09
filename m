From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] arc_emac: Use net_device_stats from struct net_device
Date: Wed, 09 Jul 2014 16:49:37 -0700 (PDT)
Message-ID: <20140709.164937.2071603402043567331.davem@davemloft.net>
References: <1404896857-29248-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34652 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751183AbaGIXti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2014 19:49:38 -0400
In-Reply-To: <1404896857-29248-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Wed,  9 Jul 2014 11:07:37 +0200

> Instead of using a privatge copy of struct net_device_stats in struct
> arc_emac_priv, use stats from struct net_device.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
