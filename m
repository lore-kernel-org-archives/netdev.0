From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Exclude duplicated checking for iface-up. This flags
 is checked in 'is_skb_forwardable' function, which is subroutine of
 'dev_forward_skb'.
Date: Thu, 30 Jun 2011 23:55:57 -0700 (PDT)
Message-ID: <20110630.235557.509225031839678013.davem@davemloft.net>
References: <1309267844-29334-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54054 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754940Ab1GAG4B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 02:56:01 -0400
In-Reply-To: <1309267844-29334-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: alex.bluesman.smirnov@gmail.com
Date: Tue, 28 Jun 2011 17:30:44 +0400

> From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
> 
> Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>

Applied.

Please put the verbose patch description in the body of your
email message, right before the signoffs, not in the subject.

The subject provides a "summary" not the entire description.
