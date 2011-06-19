From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] netpoll: copy dev name of slaves to struct netpoll
Date: Sun, 19 Jun 2011 16:13:40 -0700 (PDT)
Message-ID: <20110619.161340.1697888006248728609.davem@davemloft.net>
References: <1308303817-3498-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49003 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754170Ab1FSXNo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 19:13:44 -0400
In-Reply-To: <1308303817-3498-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amerigo Wang <amwang@redhat.com>
Date: Fri, 17 Jun 2011 17:43:37 +0800

> Otherwise we will not see the name of the slave dev in error
> message:
> 
> [  388.469446] (null):  doesn't support polling, aborting.
> 
> Signed-off-by: WANG Cong <amwang@redhat.com>

Applied, thanks.
