From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] iwmc3200top: Add Intel Wireless MultiCom 3200 top
 driver.
Date: Sun, 11 Oct 2009 03:36:47 -0700 (PDT)
Message-ID: <20091011.033647.66923614.davem@davemloft.net>
References: <1ba2fa240910100238s709c31d3s6cb612f502b1086f@mail.gmail.com>
	<20091010.185852.133969433.davem@davemloft.net>
	<1ba2fa240910110105x33fb251ar3437dd5fee552735@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-mmc@vger.kernel.org,
	yi.zhu@intel.com, inaky.perez-gonzalez@intel.com,
	cindy.h.kao@intel.com, guy.cohen@intel.com,
	ron.rindjunsky@intel.com
To: tomasw@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52257
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753571AbZJKKgw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2009 06:36:52 -0400
In-Reply-To: <1ba2fa240910110105x33fb251ar3437dd5fee552735@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tomas Winkler <tomasw@gmail.com>
Date: Sun, 11 Oct 2009 10:05:20 +0200

> Just close my eyes and there is new game to play. :)
> It's not in the patchwork, so is there any reason you are not planning
> to add it.   The patch intention was for net-next, it looks like
> I didn't mark it as such, my fault.

Because there still seems to be some confusion between which of these
bits go through John Linville as a wireless driver and which bits
go directly through me.

By default I assume John picks up "wireless" drivers and send them
to me in his wireless merges to me.

If that's not the case, explicitly do a fresh submission of this patch
and explicitly ask me to merge it.

