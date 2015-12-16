From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] net: The beginning of the end for
 NETIF_F_IP_CSUM and NETIF_F_IPV6_CSUM
Date: Tue, 15 Dec 2015 21:07:49 -0500 (EST)
Message-ID: <20151215.210749.1056291989740739490.davem@davemloft.net>
References: <1450120787-1773171-1-git-send-email-tom@herbertland.com>
	<20151215.163233.1822498299187427740.davem@davemloft.net>
	<CALx6S366Qu7+AJPe_ZHpECeaa+EeZeANXvQ4UPC7E=uft4mgdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55526 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932602AbbLPCHw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 21:07:52 -0500
In-Reply-To: <CALx6S366Qu7+AJPe_ZHpECeaa+EeZeANXvQ4UPC7E=uft4mgdg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Tue, 15 Dec 2015 14:11:05 -0800

> Looks like I may have missed a NETIF_F_ALL_CSUM in netronome driver,
> will post fix shortly.

I fixed it up for you when I applied that patch.
