From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: sock_flag() cleanup
Date: Wed, 16 May 2012 15:30:45 -0400 (EDT)
Message-ID: <20120516.153045.1736149384308994898.davem@davemloft.net>
References: <1337183827.8512.1215.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52675 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755770Ab2EPTas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 15:30:48 -0400
In-Reply-To: <1337183827.8512.1215.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 16 May 2012 17:57:07 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> - sock_flag() accepts a const pointer
> 
> - sock_flag() returns a boolean
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
