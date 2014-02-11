From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] alx: add missing stats_lock spinlock init
Date: Mon, 10 Feb 2014 17:51:03 -0800 (PST)
Message-ID: <20140210.175103.980140501807438730.davem@davemloft.net>
References: <1392060844-30995-1-git-send-email-jogreene@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jogreene@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57518 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751503AbaBKBvE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 20:51:04 -0500
In-Reply-To: <1392060844-30995-1-git-send-email-jogreene@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Greene <jogreene@redhat.com>
Date: Mon, 10 Feb 2014 14:34:04 -0500

> Trivial fix for init time stack trace occuring in
> alx_get_stats64 upon start up. Should have been part of
> commit adding the spinlock:
> f1b6b106 alx: add alx_get_stats64 operation
> 
> Signed-off-by: John Greene <jogreene@redhat.com>

Applied, thank you.
