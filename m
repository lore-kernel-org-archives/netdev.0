From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: wireless-drivers-next 2015-08-19
Date: Thu, 20 Aug 2015 14:14:30 -0700 (PDT)
Message-ID: <20150820.141430.1615778147705552773.davem@davemloft.net>
References: <87pp2ja6ar.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57227 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752679AbbHTVOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 17:14:31 -0400
In-Reply-To: <87pp2ja6ar.fsf@kamboji.qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalle Valo <kvalo@codeaurora.org>
Date: Wed, 19 Aug 2015 14:03:56 +0300

> here's one more pull request for 4.3. More info in the signed tag below.
> 
> This time I had to merge mac80211-next.git due to some iwlwifi
> dependencies and apparently that broke git-request-pull's diffstat
> again, it was showing changes which were not really coming from my tree.
> I think that's just a bug in my old git and really should update the
> tool. This time I just fixed the diffstat manually.
> 
> But please be extra careful with this pull request and please let me
> know if you have any problems.
> 
> The following changes since commit 8f9c98df949333f08b74e5df1caacf7e2c5e8552:
> 
>   mac80211: fix BIT position for TDLS WIDE extended cap (2015-08-14 17:49:53 +0200)
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next.git tags/wireless-drivers-next-for-davem-2015-08-19

Pulled, thanks.  I'll double check what I got to make sure it isn't
unexpected.
