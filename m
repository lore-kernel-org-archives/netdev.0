From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/bridge/netfilter/ebtables.c: use available error
 handling code
Date: Thu, 11 Aug 2011 05:53:33 -0700 (PDT)
Message-ID: <20110811.055333.1199553373699762518.davem@davemloft.net>
References: <1313063978-29400-1-git-send-email-julia@diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bart.de.schuymer@pandora.be, kernel-janitors@vger.kernel.org,
	kaber@trash.net, shemminger@linux-foundation.org,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: julia@diku.dk
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1313063978-29400-1-git-send-email-julia@diku.dk>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>
Date: Thu, 11 Aug 2011 13:59:38 +0200

> From: Julia Lawall <julia@diku.dk>
> 
> Free the locally allocated table and newinfo as done in adjacent error
> handling code.
> 
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied.
