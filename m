From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 ] ipv4: remove parameter from tcp_recv_urg().
Date: Wed, 18 Mar 2009 18:50:16 -0700 (PDT)
Message-ID: <20090318.185016.16408107.davem@davemloft.net>
References: <eb3ff54b0903160257n707ceddfr1a56c75b7911c1e7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60963
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753840AbZCSBu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 21:50:29 -0400
In-Reply-To: <eb3ff54b0903160257n707ceddfr1a56c75b7911c1e7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>
Date: Mon, 16 Mar 2009 11:57:20 +0200

> This patch removes an unused parameter (addr_len) from tcp_recv_urg() method in
> net/ipv4/tcp.c.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied.
