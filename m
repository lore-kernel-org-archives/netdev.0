From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1] usbnet: re-use native hex2bin()
Date: Sun, 25 Jan 2015 00:09:56 -0800 (PST)
Message-ID: <20150125.000956.888238165205391832.davem@davemloft.net>
References: <1421962032-25497-1-git-send-email-andy.shevchenko@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oneukum@suse.de, netdev@vger.kernel.org
To: andy.shevchenko@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60694 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752393AbbAYIJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jan 2015 03:09:59 -0500
In-Reply-To: <1421962032-25497-1-git-send-email-andy.shevchenko@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Thu, 22 Jan 2015 23:27:12 +0200

> Call hex2bin() library function, instead of doing conversion here.
> 
> Signed-off-by: Andy Shevchenko <andy.shevchenko@gmail.com>

Applied.
