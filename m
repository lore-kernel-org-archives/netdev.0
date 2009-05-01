From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter: use likely() in xt_info_rdlock_bh()
Date: Fri, 01 May 2009 09:10:56 -0700 (PDT)
Message-ID: <20090501.091056.177659989.davem@davemloft.net>
References: <alpine.LFD.2.00.0904280954500.22156@localhost.localdomain>
	<20090428.223708.168741998.davem@davemloft.net>
	<49FAB4FC.6040907@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, kaber@trash.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49FAB4FC.6040907@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 01 May 2009 10:38:20 +0200

> [PATCH] netfilter: use likely() in xt_info_rdlock_bh()
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied.
