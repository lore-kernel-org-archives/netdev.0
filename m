From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] nets: fix a buffer overrun
Date: Mon, 10 Nov 2008 21:37:53 -0800 (PST)
Message-ID: <20081110.213753.223716878.davem@davemloft.net>
References: <20081108023558.GB6384@ubuntu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: jianjun@zeuux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55444
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751198AbYKKFhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 00:37:54 -0500
In-Reply-To: <20081108023558.GB6384@ubuntu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jianjun Kong <jianjun@zeuux.org>
Date: Sat, 8 Nov 2008 10:35:58 +0800

> net/mac80211/debugfs_sta.c
> The trailing zero was written to state[4], it's out of bounds.
> 
> Signed-off-by: Jianjun Kong <jianjun@zeuux.org>

Applied, thank you.
