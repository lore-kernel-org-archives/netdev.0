From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: wireless-drivers-next 2016-03-14
Date: Mon, 14 Mar 2016 12:15:28 -0400 (EDT)
Message-ID: <20160314.121528.1217892668324346880.davem@davemloft.net>
References: <87y49llatn.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47032 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751087AbcCNQPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 12:15:33 -0400
In-Reply-To: <87y49llatn.fsf@kamboji.qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalle Valo <kvalo@codeaurora.org>
Date: Mon, 14 Mar 2016 10:31:48 +0200

> I know I'm late now that merge window was opened yesterday but here's
> one more set of patches I would like to get to 4.6 still. There isn't
> anything controversial so I hope this should be still safe to pull. The
> patches have been in linux-next since Friday and I haven't seen any
> reports about issues. But if you think it's too late just let me know
> and I'll resubmit these for 4.7.
> 
> The most notable part here of course is rtl8xxxu with over 100 patches.
> As the driver is new and under heavy development I think they are ok to
> take still. Otherwise there are mostly fixes with an exception of adding
> a new debugfs file to wl18xx.
> 
> Please let me know if you have any problems.

Pulled, thanks.

I really like Jes's work and I wish you had integrated it several
months ago, instead of sloshing him needlessly through a non-stop
cycle of very nit-picky issues, just FYI.
