From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv4: remove the useless argument from
 ip_tunnel_hash()
Date: Tue, 21 Jan 2014 16:49:12 -0800 (PST)
Message-ID: <20140121.164912.1679504796861335077.davem@davemloft.net>
References: <52DB903E.9050301@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38667 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752447AbaAVAtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 19:49:13 -0500
In-Reply-To: <52DB903E.9050301@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Sun, 19 Jan 2014 16:43:42 +0800

> 
> Since commit c544193214("GRE: Refactor GRE tunneling code")
> introduced function ip_tunnel_hash(), the argument itn is no 
> longer in use, so remove it.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

Applied, thanks.
