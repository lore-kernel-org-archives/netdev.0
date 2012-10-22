From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] unix: Remove unused field from unix_sock
Date: Sun, 21 Oct 2012 20:37:43 -0400 (EDT)
Message-ID: <20121021.203743.2025532949963406564.davem@davemloft.net>
References: <5080F30C.2090206@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54824 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753856Ab2JVAhp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2012 20:37:45 -0400
In-Reply-To: <5080F30C.2090206@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Fri, 19 Oct 2012 10:28:28 +0400

> The struct sock *other one seem to be unused. Grep and make do not object.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

Applied.
