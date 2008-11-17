From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: make sure struct dst_entry refcount is aligned on
 64 bytes
Date: Sun, 16 Nov 2008 19:46:51 -0800 (PST)
Message-ID: <20081116.194651.204600110.davem@davemloft.net>
References: <491D3F18.5030505@cosmosbay.com>
	<20081114093613.GA2834@x200.localdomain>
	<491D5725.50006@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, netdev@vger.kernel.org, shemminger@vyatta.com,
	yanmin_zhang@linux.intel.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48618
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755498AbYKQDqv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2008 22:46:51 -0500
In-Reply-To: <491D5725.50006@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 14 Nov 2008 11:47:01 +0100

> [PATCH] net: make sure struct dst_entry refcount is aligned on 64 bytes

Applied to net-next-2.6, thanks Eric.
