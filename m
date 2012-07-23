From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net/for-next V1 1/1] IB/ipoib: break linkage to
 neighbouring system
Date: Mon, 23 Jul 2012 19:17:43 +0200
Message-ID: <1343063863.2626.11028.camel@edumazet-glaptop>
References: <1342703938-29904-1-git-send-email-ogerlitz@mellanox.com>
	 <1342703938-29904-2-git-send-email-ogerlitz@mellanox.com>
	 <CAJZOPZ+kRcBjJgB_HaMqeuB5E-SLSqskgoaLZ_hvVx4KffHgpA@mail.gmail.com>
	 <500D82AD.2040508@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: roland@kernel.org, davem@davemloft.net,
	Christoph Lameter <cl@linux.com>, linux-rdma@vger.kernel.org,
	erezsh@mellanox.com, Shlomo Pongratz <shlomop@mellanox.com>,
	netdev@vger.kernel.org
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:47198 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753828Ab2GWRRu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 13:17:50 -0400
In-Reply-To: <500D82AD.2040508@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-23 at 19:58 +0300, Or Gerlitz wrote:

> Sorry for the possible spam, but resending (last time forgot to put Eric 
> on the "to" list so he might missed it, also added Christoph) - this is 
> a fix for very long time bug in IPoIB and we do want it to be reviewed 
> && and hopefully accepted, or if needed get feedback and fix/change.
> 
> So, any further feedback? there was one feedback on V0, not to use read 
> lock for RCU protected
> hash table lookup, and it was addressed in V1.
> 

I have no idea of what you are talking about, I have not the patch or a
copy of it ;)
