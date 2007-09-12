From: David Miller <davem@davemloft.net>
Subject: Re: [-mm patch] net/sctp/socket.c: make 3 variables static
Date: Wed, 12 Sep 2007 06:18:45 -0700 (PDT)
Message-ID: <20070912.061845.26289062.davem@davemloft.net>
References: <20070831215822.26e1432b.akpm@linux-foundation.org>
	<20070909202554.GY3563@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, vladislav.yasevich@hp.com,
	sri@us.ibm.com, linux-kernel@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:54410
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757550AbXILNTF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 09:19:05 -0400
In-Reply-To: <20070909202554.GY3563@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@kernel.org>
Date: Sun, 9 Sep 2007 22:25:54 +0200

> This patch makes the following needlessly globalvariables static:
> - sctp_memory_pressure
> - sctp_memory_allocated
> - sctp_sockets_allocated
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

Applied, thanks.
