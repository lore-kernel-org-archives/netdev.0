From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] net: qualcomm: Fix dependency
Date: Tue, 11 Nov 2014 18:13:07 -0500 (EST)
Message-ID: <20141111.181307.965812220900036791.davem@davemloft.net>
References: <1415745480-23692-1-git-send-email-stefan.wahren@i2se.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stefan.wahren@i2se.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34947 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752263AbaKKXNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 18:13:08 -0500
In-Reply-To: <1415745480-23692-1-git-send-email-stefan.wahren@i2se.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Wahren <stefan.wahren@i2se.com>
Date: Tue, 11 Nov 2014 22:38:00 +0000

> This patch removes the dependency of the VENDOR entry and fixes
> the QCA7000 one.
> 
> Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
> ---
> 
> change in V2: remove dependency of the VENDOR entry suggested by
> David Miller

Yep, looks good, applied.
