From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/3] pch_gbe: few clean ups to the driver
Date: Fri, 28 Jun 2013 21:38:16 -0700 (PDT)
Message-ID: <20130628.213816.474586551111862244.davem@davemloft.net>
References: <1372417374-28128-1-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dvhart@linux.intel.com, joe@perches.com
To: andriy.shevchenko@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46260 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750950Ab3F2EiR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jun 2013 00:38:17 -0400
In-Reply-To: <1372417374-28128-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Fri, 28 Jun 2013 14:02:51 +0300

> There are three clean ups to the driver.
> 
> Since v2:
> - the additional arguments on subsequent lines are realigned to the open
>   parenthesis
> 
> Since v1:
> - remove hunk that is not belong the topic
> - address Joe's comments
> 
> Andy Shevchenko (3):
>   pch_gbe: remove inline keyword for exported functions
>   pch_gbe: convert pr_* to netdev_*
>   pch_gbe: use managed functions pcim_* and devm_*

Series applied, thanks.
