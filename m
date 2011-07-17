From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add 802.1ad / 802.1ah / QinQ ethertypes
Date: Sun, 17 Jul 2011 12:33:51 -0700 (PDT)
Message-ID: <20110717.123351.1687363011884325125.davem@davemloft.net>
References: <1310927532-3429374-1-git-send-email-equinox@diac24.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: equinox@diac24.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41351 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754797Ab1GQTfa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jul 2011 15:35:30 -0400
In-Reply-To: <1310927532-3429374-1-git-send-email-equinox@diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lamparter <equinox@diac24.net>
Date: Sun, 17 Jul 2011 20:32:12 +0200

> define ETH_P_8021AD to 88a8 (assigned by IEEE) and add ETH_P_QINQ{1,2,3}
> for the pre-standard 9{1,2,3}00 types. all of them use 802.1q frame
> format, with 1 bit used differently in some cases.
> 
> also define ETH_P_8021AH to 88e7 (assigned by IEEE). this is Mac-in-Mac
> and uses a different, 16-byte header.
> 
> Signed-off-by: David Lamparter <equinox@diac24.net>

Applied.
