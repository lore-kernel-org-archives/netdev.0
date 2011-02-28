From: David Miller <davem@davemloft.net>
Subject: Re: [V4 PATCH 1/3] bonding: sync netpoll code with bridge
Date: Sun, 27 Feb 2011 16:12:10 -0800 (PST)
Message-ID: <20110227.161210.242134645.davem@davemloft.net>
References: <1298022215-21059-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, nhorman@redhat.com,
	herbert@gondor.hengli.com.au, fubar@us.ibm.com,
	netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298022215-21059-1-git-send-email-amwang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amerigo Wang <amwang@redhat.com>
Date: Fri, 18 Feb 2011 17:43:32 +0800

> V4: rebase to net-next-2.6
> V3: remove an useless #ifdef.
> 
> This patch unifies the netpoll code in bonding with netpoll code in bridge,
> thanks to Herbert that code is much cleaner now.
> 
> Signed-off-by: WANG Cong <amwang@redhat.com>

Applied.
