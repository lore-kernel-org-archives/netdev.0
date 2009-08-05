From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix spinlock use in alloc_netdev_mq()
Date: Wed, 05 Aug 2009 08:37:33 -0700 (PDT)
Message-ID: <20090805.083733.81430600.davem@davemloft.net>
References: <20090805071411.GA9217@elte.hu>
	<20090805071658.GA14073@elte.hu>
	<20090805084746.GA3897@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, a.p.zijlstra@chello.nl,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39334
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755809AbZHEPhY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 11:37:24 -0400
In-Reply-To: <20090805084746.GA3897@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Wed, 5 Aug 2009 10:47:47 +0200

>>Signed-off-by: Ingo Molnar <mingo@elte.hu>
> Acked-by: Jiri Pirko <jpirko@redhat.com>

Applied, thanks everyone.
