From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2010-08-10
Date: Tue, 10 Aug 2010 16:00:59 -0700 (PDT)
Message-ID: <20100810.160059.27791359.davem@davemloft.net>
References: <20100810204251.GB2728@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39699
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933613Ab0HJXAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 19:00:40 -0400
In-Reply-To: <20100810204251.GB2728@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Tue, 10 Aug 2010 16:42:51 -0400

> Here are a few more fixes intended for 2.6.36.  Included are a locking
> fix for cfg80211, a fix for iwlagn to prevent it from using RTS/CTS
> or CTS-to-self protection on every frame (even inappropriately),
> a reversion of a mistakenly added PCI ID from p54, and a simple fix
> for some build breakage some have been experiencing in libertas.
> Also included are a handful of Bluetooth fixes by way of Marcel.

Pulled, thanks a lot John.
