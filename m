From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: Fix double sizeof in new tcp_metrics code
Date: Thu, 01 Nov 2012 12:00:50 -0400 (EDT)
Message-ID: <20121101.120050.1731582793025597129.davem@davemloft.net>
References: <1351634589-4861-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60607 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933964Ab2KAQAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2012 12:00:54 -0400
In-Reply-To: <1351634589-4861-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Wed, 31 Oct 2012 00:03:09 +0200

> 	Fix double sizeof when parsing IPv6 address from
> user space because it breaks get/del by specific IPv6 address.
> 
> 	Problem noticed by David Binderman:
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=49171
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Applied, thanks.
