From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: fix comment typo for __skb_alloc_pages()
Date: Tue, 03 Sep 2013 22:17:57 -0400 (EDT)
Message-ID: <20130903.221757.114138119367464713.davem@davemloft.net>
References: <1377869297-19805-1-git-send-email-f.fainelli@gmail.com>
	<1377873374-11350-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53841 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761682Ab3IDCSC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 22:18:02 -0400
In-Reply-To: <1377873374-11350-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Florian Fainelli" <f.fainelli@gmail.com>
Date: Fri, 30 Aug 2013 15:36:14 +0100

> The name of the function in the comment is __skb_alloc_page() while we
> are actually commenting __skb_alloc_pages(). Fix this typo and make it
> a valid kernel doc comment.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks.
