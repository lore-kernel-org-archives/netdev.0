From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2010-09-01
Date: Wed, 01 Sep 2010 13:01:15 -0700 (PDT)
Message-ID: <20100901.130115.146355657.davem@davemloft.net>
References: <20100901181711.GG2486@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33724
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754149Ab0IAUA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 16:00:58 -0400
In-Reply-To: <20100901181711.GG2486@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Wed, 1 Sep 2010 14:17:11 -0400

> This batch of fixes is intended for 2.6.36.
> 
> Included is a libertas fix for an alignment error introduced by a change
> introduced through another tree during the merge window, an ath5k fix to
> avoid a NULL pointer dereference when the rate control fails to give it
> a usable transmission rate (which is another bug), a p54 fix to avoid
> false transmission failure reports (which prevent power saving), a
> fix for a mac80211 timer leak, a MAINTAINERS fix for a broken URL, a
> wireless extension fix to plug an information leak, a fix for a lockdep
> warning when cfg80211 registers its rfkill device, and a couple of ath9k
> fixes related to regulatory compliance.
> 
> Please let me know if there are problems!

Pulled, thanks John.
