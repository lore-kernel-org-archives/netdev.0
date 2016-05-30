From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 1/1] net/lapb: tuse %*ph to dump buffers
Date: Sun, 29 May 2016 22:33:34 -0700 (PDT)
Message-ID: <20160529.223334.1630974648225342747.davem@davemloft.net>
References: <1464263032-96325-1-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maxime.jayat@mobile-devices.fr
To: andriy.shevchenko@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49624 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751141AbcE3Fdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2016 01:33:35 -0400
In-Reply-To: <1464263032-96325-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Thu, 26 May 2016 14:43:52 +0300

> Use %*ph specifier to dump small buffers in hex format instead doing this
> byte-by-byte.
> 
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

Applied.
