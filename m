From: David Miller <davem@davemloft.net>
Subject: Re: [V4 PATCH 2/3] netpoll: remove IFF_IN_NETPOLL flag
Date: Sun, 27 Feb 2011 16:12:16 -0800 (PST)
Message-ID: <20110227.161216.116376267.davem@davemloft.net>
References: <1298022215-21059-1-git-send-email-amwang@redhat.com>
	<1298022215-21059-2-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, nhorman@redhat.com,
	herbert@gondor.hengli.com.au, fubar@us.ibm.com, horms@verge.net.au,
	jpirko@redhat.com, kaber@trash.net, nhorman@tuxdriver.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298022215-21059-2-git-send-email-amwang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amerigo Wang <amwang@redhat.com>
Date: Fri, 18 Feb 2011 17:43:33 +0800

> V4: rebase to net-next-2.6
> 
> This patch removes the flag IFF_IN_NETPOLL, we don't need it any more since
> we have netpoll_tx_running() now.
> 
> Signed-off-by: WANG Cong <amwang@redhat.com>

Applied.
