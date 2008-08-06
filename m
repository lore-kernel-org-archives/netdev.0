From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 1/2] ipv4: replace dst_metric() with dst_mtu()
 in net/ipv4/route.c.
Date: Wed, 06 Aug 2008 02:33:58 -0700 (PDT)
Message-ID: <20080806.023358.40581411.davem@davemloft.net>
References: <eb3ff54b0808050600s1b49d7dp8d6b8db8cc9203c0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48596
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754985AbYHFJd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 05:33:57 -0400
In-Reply-To: <eb3ff54b0808050600s1b49d7dp8d6b8db8cc9203c0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rami Rosen" <ramirose@gmail.com>
Date: Tue, 5 Aug 2008 16:00:21 +0300

> This patch replaces dst_metric() with dst_mtu() in net/ipv4/route.c.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied.
