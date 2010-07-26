From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2010-07-26
Date: Mon, 26 Jul 2010 13:30:52 -0700 (PDT)
Message-ID: <20100726.133052.70189940.davem@davemloft.net>
References: <20100726194919.GH3903@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40434
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755216Ab0GZUae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jul 2010 16:30:34 -0400
In-Reply-To: <20100726194919.GH3903@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Mon, 26 Jul 2010 15:49:20 -0400

> The following changes since commit 3b87956ea645fb4de7e59c7d0aa94de04be72615:
> 
>   net sched: fix race in mirred device removal (2010-07-24 21:04:20 -0700)
> 
> are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master
> 
> John W. Linville (1):
>       wireless: use netif_rx_ni in ieee80211_send_layer2_update
> 
> Ming Lei (1):
>       ath9k: fix dma direction for map/unmap in ath_rx_tasklet

Pulled, thanks John.
