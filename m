From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 0/3] be2net fixes
Date: Thu, 30 Jun 2011 23:59:36 -0700 (PDT)
Message-ID: <20110630.235936.992101019508675854.davem@davemloft.net>
References: <1309426301-15783-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36312 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755035Ab1GAG7j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 02:59:39 -0400
In-Reply-To: <1309426301-15783-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Thu, 30 Jun 2011 15:01:41 +0530

> Pls apply.
> 
> Sathya Perla (3):
>   be2net: fix certain cmd failure logging
>   be2net: create/destroy rx-queues on interface open/close
>   be2net: clear intr bit in be_probe()

Applied, but I had to fix up many whitespace problems.

Some of your lines began with mixes of spaces and tabs.

Some of your lines had trailing whitespace.
