From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] dev: add support of flag IFF_NOPROC
Date: Thu, 03 Oct 2013 15:09:47 -0400 (EDT)
Message-ID: <20131003.150947.2179820478039260398.davem@davemloft.net>
References: <1380806905-4461-1-git-send-email-nicolas.dichtel@6wind.com>
	<20131003104627.411f5cc4@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37955 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754349Ab3JCTJv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 15:09:51 -0400
In-Reply-To: <20131003104627.411f5cc4@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 3 Oct 2013 10:46:27 -0700

> What about speeding up proc or sysfs? Or providing a bulk create/destroy.

+1 +1 +1

This will benefit more people than the just the envisioned users for
this IFF_NOPROC thing.

I really don't want to take the IFF_NOPROC approach.
