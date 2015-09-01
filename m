From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tun_dst: Remove opts_size
Date: Mon, 31 Aug 2015 21:23:52 -0700 (PDT)
Message-ID: <20150831.212352.439217655926798769.davem@davemloft.net>
References: <1441076757-2349-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54098 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750949AbbIAEXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 00:23:52 -0400
In-Reply-To: <1441076757-2349-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Mon, 31 Aug 2015 20:05:57 -0700

> opts_size is only written and never read. Following patch
> removes this unused variable.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied, thanks.
