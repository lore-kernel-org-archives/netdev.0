From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: wireless-drivers-next 2015-12-07
Date: Tue, 08 Dec 2015 12:40:24 -0500 (EST)
Message-ID: <20151208.124024.486806330737510636.davem@davemloft.net>
References: <878u56cfsq.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38605 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434AbbLHRk0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 12:40:26 -0500
In-Reply-To: <878u56cfsq.fsf@kamboji.qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalle Valo <kvalo@codeaurora.org>
Date: Mon, 07 Dec 2015 19:46:45 +0200

> here's the first "real" pull request after the wireless directory
> reorganisation. Nothing really out ordinary, new features and bugfixes
> as usual. This time there's a regression in ath10k because of a bugfix
> in wireless-drivers.git which conflicted with a patch in
> wireless-drivers-next.git. But it should be easy to fix, just follow
> what Stephen did in in linux-next:
> 
> http://article.gmane.org/gmane.linux.kernel.next/37391
> 
> Please let me know if you have any problems.

Pulled, thanks for the heads-up about the conflicts.
