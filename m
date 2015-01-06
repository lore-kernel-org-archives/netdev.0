From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qla3xxx: don't allow never end busy loop
Date: Tue, 06 Jan 2015 17:41:55 -0500 (EST)
Message-ID: <20150106.174155.1469700455231157851.davem@davemloft.net>
References: <1420579073-24637-1-git-send-email-andy.shevchenko@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com
To: andy.shevchenko@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56693 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750844AbbAFWl4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 17:41:56 -0500
In-Reply-To: <1420579073-24637-1-git-send-email-andy.shevchenko@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Tue,  6 Jan 2015 23:17:53 +0200

> The counter variable wasn't increased at all which may stuck under
> certain circumstances.
> 
> Signed-off-by: Andy Shevchenko <andy.shevchenko@gmail.com>

Applied, thanks.
