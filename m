From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1] cxgb3: re-use native hex2bin()
Date: Sun, 25 Jan 2015 00:10:03 -0800 (PST)
Message-ID: <20150125.001003.2295849527837217015.davem@davemloft.net>
References: <1421962659-25885-1-git-send-email-andy.shevchenko@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, santosh@chelsio.com
To: andy.shevchenko@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60696 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752514AbbAYIKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jan 2015 03:10:04 -0500
In-Reply-To: <1421962659-25885-1-git-send-email-andy.shevchenko@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Thu, 22 Jan 2015 23:37:39 +0200

> Call hex2bin() library function instead of doing conversion here.
> 
> Signed-off-by: Andy Shevchenko <andy.shevchenko@gmail.com>

Applied.
