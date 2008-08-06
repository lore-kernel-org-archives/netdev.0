From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 2/2] ipv6: replace dst_metric() with dst_mtu()
 in net/ipv6/route.c.
Date: Wed, 06 Aug 2008 02:34:30 -0700 (PDT)
Message-ID: <20080806.023430.189770340.davem@davemloft.net>
References: <eb3ff54b0808050601ua3ff5e0q28a808b5f381fa8c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48599
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755139AbYHFJe3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 05:34:29 -0400
In-Reply-To: <eb3ff54b0808050601ua3ff5e0q28a808b5f381fa8c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rami Rosen" <ramirose@gmail.com>
Date: Tue, 5 Aug 2008 16:01:34 +0300

> This patch replaces dst_metric() with dst_mtu() in net/ipv6/route.c.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied.
