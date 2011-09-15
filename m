From: David Miller <davem@redhat.com>
Subject: Re: pull request: wireless 2011-09-15
Date: Thu, 15 Sep 2011 17:13:20 -0400 (EDT)
Message-ID: <20110915.171320.2277087899608297535.davem@redhat.com>
References: <20110915194814.GC24589@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20649 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934775Ab1IOVN3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Sep 2011 17:13:29 -0400
In-Reply-To: <20110915194814.GC24589@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Thu, 15 Sep 2011 15:48:15 -0400

> Here is a batch of fixes intended for 3.1.  Included is a calibration
> fix for ath9k that avoids a hang, a couple of rtlwifi fixes for
> connection failures, a mac80211 locking fix, a couple of iwlagn fixes
> (including a corruption fix), an ath9k oops fix, an initialization
> fix for AR9330 hardware in ath9k, and a patch to avoid a needless
> BUG_ON in iwlegacy.
> 
> Please let me know if there are problems!

Pulled, thanks John.
