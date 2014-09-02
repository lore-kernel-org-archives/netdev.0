From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net-timestamp: expand documentation
Date: Mon, 01 Sep 2014 21:49:24 -0700 (PDT)
Message-ID: <20140901.214924.1898016642519769639.davem@davemloft.net>
References: <1409534867-32710-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47424 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750967AbaIBEtZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 00:49:25 -0400
In-Reply-To: <1409534867-32710-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Sun, 31 Aug 2014 21:27:47 -0400

> Expand Documentation/networking/timestamping.txt with new
> interfaces and bytestream timestamping. Also minor
> cleanup of the other text.
> 
> Import txtimestamp.c test of the new features.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied, thanks for the test case.
