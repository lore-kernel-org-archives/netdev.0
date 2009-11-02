From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ifb: RCU locking avoids touching dev
 refcount
Date: Sun, 01 Nov 2009 23:57:14 -0800 (PST)
Message-ID: <20091101.235714.116279325.davem@davemloft.net>
References: <4AEE71EC.7040208@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40368
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754166AbZKBH4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 02:56:49 -0500
In-Reply-To: <4AEE71EC.7040208@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 02 Nov 2009 06:45:16 +0100

> Avoids touching dev refcount in hotpath
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
