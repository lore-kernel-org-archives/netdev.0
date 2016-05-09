From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 1/1] ISDN: eicon: replace custom hex_asc_lo() /
 hex_pack_byte()
Date: Sun, 08 May 2016 23:55:42 -0400 (EDT)
Message-ID: <20160508.235542.971064628779476626.davem@davemloft.net>
References: <1462557323-102678-1-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mac@melware.de, netdev@vger.kernel.org
To: andriy.shevchenko@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53907 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751011AbcEIDzp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2016 23:55:45 -0400
In-Reply-To: <1462557323-102678-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Fri,  6 May 2016 20:55:23 +0300

> Instead of custom approach re-use generic helpers to convert byte to hex
> format.
> 
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

Applied.
