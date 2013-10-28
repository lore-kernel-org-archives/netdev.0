From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/5] 6lowpan: trivial changes
Date: Mon, 28 Oct 2013 19:48:48 -0400 (EDT)
Message-ID: <20131028.194848.220582521993210661.davem@davemloft.net>
References: <1382952260-23174-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, werner@almesberger.net,
	dbaryshkov@gmail.com, netdev@vger.kernel.org
To: alex.aring@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38782 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757709Ab3J1Xsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 19:48:52 -0400
In-Reply-To: <1382952260-23174-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Aring <alex.aring@gmail.com>
Date: Mon, 28 Oct 2013 10:24:15 +0100

> This patch series includes some trivial changes to prepare the 6lowpan stack
> for upcomming patch-series which mainly fix fragmentation according to rfc4944
> and udp handling(which is currently broken).
> 
> Changes since v3:
>   - really fix intendation in patch 3/5
> 
> Changes since v2:
>   - change intendation in patch 3/5
>   - fix typo in 5/5 unecessary -> unnecessary
>   - add missing 6lowpan tag in cover-letter

Series applied, thanks.
