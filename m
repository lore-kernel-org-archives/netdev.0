From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ieee802154: at86rf230: Remove empty suspend/resume
 callbacks
Date: Fri, 15 Feb 2013 15:35:56 -0500 (EST)
Message-ID: <20130215.153556.296497142905270422.davem@davemloft.net>
References: <1360933409-2529-1-git-send-email-lars@metafoo.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: lars@metafoo.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44417 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875Ab3BOUf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 15:35:58 -0500
In-Reply-To: <1360933409-2529-1-git-send-email-lars@metafoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lars-Peter Clausen <lars@metafoo.de>
Date: Fri, 15 Feb 2013 14:03:29 +0100

> There is no need to implement empty suspend/resume callbacks if there is nothing
> to do during suspend/resume. The drivers will behave the same with no callbacks
> or empty callbacks during suspend/resume.
> 
> Signed-off-by: Lars-Peter Clausen <lars@metafoo.de>

Applied.
