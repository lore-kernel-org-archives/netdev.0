From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sock-diag: Report shutdown for inet and unix
 sockets (v2)
Date: Tue, 23 Oct 2012 14:58:46 -0400 (EDT)
Message-ID: <20121023.145846.920794279491742095.davem@davemloft.net>
References: <5086E224.4030103@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43385 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756771Ab2JWS6v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 14:58:51 -0400
In-Reply-To: <5086E224.4030103@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Tue, 23 Oct 2012 22:29:56 +0400

> Make it simple -- just put new nlattr with just sk->sk_shutdown bits.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

That's a lot better, applied, thanks.
