From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] atm: nicstar: re-use native mac_pton() helper
Date: Wed, 04 Sep 2013 14:42:29 -0400 (EDT)
Message-ID: <20130904.144229.1072854884766539343.davem@davemloft.net>
References: <1378210424-14781-1-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, andy.shevchenko@gmail.com
To: andriy.shevchenko@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44354 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754197Ab3IDSmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 14:42:31 -0400
In-Reply-To: <1378210424-14781-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Tue,  3 Sep 2013 15:13:43 +0300

> From: Andy Shevchenko <andy.shevchenko@gmail.com>
> 
> There is a nice helper to parse MAC. Let's use it and remove custom
> implementation.
> 
> Signed-off-by: Andy Shevchenko <andy.shevchenko@gmail.com>

Applied.
