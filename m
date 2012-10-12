From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] unix: Remove unused field from unix_sock
Date: Fri, 12 Oct 2012 15:26:47 -0400 (EDT)
Message-ID: <20121012.152647.1915092593654569844.davem@davemloft.net>
References: <50782ED6.7090704@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50630 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751665Ab2JLT0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2012 15:26:49 -0400
In-Reply-To: <50782ED6.7090704@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Fri, 12 Oct 2012 18:53:10 +0400

> The struct sock *other one seem to be unused. Grep and make do not object.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

Please resend this when net-next opens back up, thanks.
