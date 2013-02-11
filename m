From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cfg80211: configuration for WoWLAN over TCP
Date: Mon, 11 Feb 2013 13:45:09 -0500 (EST)
Message-ID: <20130211.134509.1039159764058878012.davem@davemloft.net>
References: <1360596853-13610-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	johannes.berg@intel.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40931 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758808Ab3BKSpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 13:45:12 -0500
In-Reply-To: <1360596853-13610-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Mon, 11 Feb 2013 16:34:13 +0100

> From: Johannes Berg <johannes.berg@intel.com>
> 
> Intel Wireless devices are able to make a TCP connection
> after suspending, sending some data and waking up when
> the connection receives wakeup data (or breaks). Add the
> WoWLAN configuration and feature advertising API for it.
> 
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

No objections from me:

Acked-by: David S. Miller <davem@davemloft.net>
