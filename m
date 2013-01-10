From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bfin_mac: Restore hardware time-stamping dependency on
 BF518
Date: Thu, 10 Jan 2013 14:37:53 -0800 (PST)
Message-ID: <20130110.143753.1109222983379394048.davem@davemloft.net>
References: <1357828948-22682-1-git-send-email-lars@metafoo.de>
	<20130110164016.GA2295@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lars@metafoo.de, uclinux-dist-devel@blackfin.uclinux.org,
	netdev@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34541 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751987Ab3AJWhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 17:37:54 -0500
In-Reply-To: <20130110164016.GA2295@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Thu, 10 Jan 2013 17:40:16 +0100

> On Thu, Jan 10, 2013 at 03:42:28PM +0100, Lars-Peter Clausen wrote:
>> 
>> This patch adds back the dependency on BF518, and since it does not make sense
>> to expose this config option when the blackfin MAC driver is not enabled also
>> restore the dependency on BFIN_MAC.
> 
> Thanks a lot for fixing this.
> 
> Acked-by: Richard Cochran <richardcochran@gmail.com>

Applied.
