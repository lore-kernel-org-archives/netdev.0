From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] vsock: fix missing cleanup when misc_register failed
Date: Sun, 18 Oct 2015 18:50:13 -0700 (PDT)
Message-ID: <20151018.185013.1508341298626923808.davem@davemloft.net>
References: <1445182556-24073-1-git-send-email-omarapazanadi@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: omarapazanadi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48568 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752114AbbJSBd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2015 21:33:58 -0400
In-Reply-To: <1445182556-24073-1-git-send-email-omarapazanadi@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <omarapazanadi@gmail.com>
Date: Sun, 18 Oct 2015 23:35:56 +0800

> reset transport and unlock if misc_register failed.
> 
> Signed-off-by: Gao feng <omarapazanadi@gmail.com>

It's extremely disappointing that it took you three revisions
just to put together a submission that actually compiles.

That shows me that you put a very low amount of care into your
submission, and if you don't care about your change why should I?
