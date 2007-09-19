From: David Miller <davem@davemloft.net>
Subject: Re: Please pull 'z1211' branch of wireless-2.6
Date: Wed, 19 Sep 2007 12:56:41 -0700 (PDT)
Message-ID: <20070919.125641.62342823.davem@davemloft.net>
References: <20070919181005.GB5483@tuxdriver.com>
	<20070919.115903.75429061.davem@davemloft.net>
	<200709192123.16884.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, jeff@garzik.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, dsd@gentoo.org, kune@deine-taler.de
To: mb@bu3sch.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40699
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750917AbXIST4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 15:56:42 -0400
In-Reply-To: <200709192123.16884.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Buesch <mb@bu3sch.de>
Date: Wed, 19 Sep 2007 21:23:16 +0200

> John, please also note that the following patch is not merged, yet.
> http://bu3sch.de/patches/wireless-dev/20070915-1740/patches/006-zd-fix-tx-status.patch
> Without it ratecontrol does not work. It does neither scale the rate
> up nor down. This patch fixes both.

I agreed with John to merge this in myself, but this patch
applied to the old driver aparently, not the new z1211 one.

Can you resend this patch against the new driver so I can
add it to net-2.6.24?

Thanks!
