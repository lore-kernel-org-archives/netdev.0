From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] include/linux/skbuff.h: move CONFIG_XFRM
 check inside the skb_sec_path()
Date: Mon, 30 Sep 2013 22:25:57 -0700 (PDT)
Message-ID: <20130930.222557.2127518665116094800.davem@davemloft.net>
References: <1380463645-4633-1-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kda@linux-powerpc.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42730 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751093Ab3JAFS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 01:18:58 -0400
In-Reply-To: <1380463645-4633-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Kirjanov <kda@linux-powerpc.org>
Date: Sun, 29 Sep 2013 18:07:25 +0400

> And thus we have only one function definition
> 
> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>

This does not apply cleanly to the current net-next tree.
