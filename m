From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ppp: fix lost fragments in ppp_mp_explode()
Date: Sun, 02 Aug 2009 12:27:59 -0700 (PDT)
Message-ID: <20090802.122759.19460185.davem@davemloft.net>
References: <4A6EFEB4.2000500@netservers.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, gabriele.paoloni@intel.com,
	netdev@vger.kernel.org, linux-ppp@vger.kernel.org
To: ben@netservers.co.uk
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <4A6EFEB4.2000500@netservers.co.uk>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben McKeegan <ben@netservers.co.uk>
Date: Tue, 28 Jul 2009 14:35:48 +0100

> 
> This patch fixes the corner cases where the sum of MTU of the free
> channels (adjusted for fragmentation overheads) is less than the MTU
> of PPP link.

Applied, thanks.

