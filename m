From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-next 2013-10-17
Date: Thu, 17 Oct 2013 16:15:05 -0400 (EDT)
Message-ID: <20131017.161505.2278932043612781921.davem@davemloft.net>
References: <20131017182339.GC1812@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46878 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758245Ab3JQUPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 16:15:07 -0400
In-Reply-To: <20131017182339.GC1812@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Thu, 17 Oct 2013 14:23:40 -0400

> This is a batch of updates intended for the 3.13 stream...
> 
> The biggest item of interest in here is wcn36xx, the new mac80211
> driver for Qualcomm WCN3660/WCN3680 hardware.
> 
> Regarding the mac80211 bits, Johannes says:
> 
> "We have an assortment of cleanups and new features, of which the
> biggest one is probably the channel-switch support in IBSS. Nothing
> else really stands out much."
> 
> On top of that, the ath9k and rt2x00 get a lot of update action from
> Felix Fietkau and Gabor Juhos, respectively.  There are a handful of
> updates to other drivers here and there as well.
> 
> Please let me know if there are problems!

Pulled, thanks John.
