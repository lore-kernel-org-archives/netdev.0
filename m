From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] gre: fix improper error handling
Date: Fri, 22 Jul 2011 06:01:25 -0700 (PDT)
Message-ID: <20110722.060125.445521078131142411.davem@davemloft.net>
References: <201107221326.10597.xeb@mail.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xeb@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46510 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753785Ab1GVNBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2011 09:01:32 -0400
In-Reply-To: <201107221326.10597.xeb@mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kozlov <xeb@mail.ru>
Date: Fri, 22 Jul 2011 13:26:10 +0400

> Fix improper protocol err_handler, current implementation is fully 
> unapplicable and may cause kernel crash due to double kfree_skb.
> 
> Signed-off-by: Dmitry Kozlov <xeb@mail.ru>

Your patch has been corrupted by your email client.

For example, it has changed tab characters into sequences of spaces.

This makes your patch unusable.

Please read Documentation/email-clients.txt to learn how to fix this,
and after fixing your setup send a test patch to yourself and try
to apply it just as we would when you post it here.

Only after this self-test passes, should you try to resubmit your
patch.

Thank you.
