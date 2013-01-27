From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: Increment of LINUX_MIB_LISTENOVERFLOWS in
 tcp_v4_conn_request()
Date: Sun, 27 Jan 2013 01:41:04 -0500 (EST)
Message-ID: <20130127.014104.483003490808493656.davem@davemloft.net>
References: <1359097408-9786-1-git-send-email-niv@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leandro.lucarella@sociomantic.com,
	niv@us.ibm.com
To: niveditasinghvi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55533 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756014Ab3A0GlG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jan 2013 01:41:06 -0500
In-Reply-To: <1359097408-9786-1-git-send-email-niv@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nivedita Singhvi <niveditasinghvi@gmail.com>
Date: Thu, 24 Jan 2013 23:03:28 -0800

> We drop a connection request if the accept backlog, syn queue are full when processing reaches tcp_v4_conn_request(). Increment the appropriate counter so this isn't silent, for accurate stats and help in debugging.
> 
> Signed-off-by: Nivedita Singhvi <niv@us.ibm.com>

Please resend with the commit message changes suggested to you.
