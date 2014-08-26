From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] bnx2x: `fixes' patch-series
Date: Mon, 25 Aug 2014 17:30:50 -0700 (PDT)
Message-ID: <20140825.173050.83808705245684919.davem@davemloft.net>
References: <1408978113-27902-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39870 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752606AbaHZAav (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 20:30:51 -0400
In-Reply-To: <1408978113-27902-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Mon, 25 Aug 2014 17:48:28 +0300

> This series contains mostly bug fixes, but never the less is intended
> for `net-next' and not `net', as:
>   - Some of the fixes are quite insignificant [`VF clean statistics',
>     `ethtool -d might cause timeout in log'].
>   - Some only recently were submitted to `net-next' [`Fix timesync endianity'].
>   - Some are not usually compiled as part of the kernel [`Fix stop-on-error'].
> 
> Dave - please consider applying this series to `net-next'; If you prefer,
> I can break this series into 2 parts [one for `net' and the other for
> `net-next'] - but personally I don't see much benefit in it.

Series applied to net-next, thanks.
