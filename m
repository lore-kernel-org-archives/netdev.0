From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm: nicstar: fix regression made by previous patch
Date: Mon, 16 Sep 2013 00:54:06 -0400 (EDT)
Message-ID: <20130916.005406.1625539714273042043.davem@davemloft.net>
References: <1379084458-23793-1-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org
To: andriy.shevchenko@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58415 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752323Ab3IPEyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 00:54:07 -0400
In-Reply-To: <1379084458-23793-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Fri, 13 Sep 2013 18:00:58 +0300

> The commit 8390f814 "atm: nicstar: re-use native mac_pton() helper" did a
> usefull thing. However, mac_pton() returns 1 in the case of the successfully
> parsed input. This patch fixes a typo.
> 
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

Applied.
