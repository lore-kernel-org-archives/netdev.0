From: David Miller <davem@davemloft.net>
Subject: Re: [V4 PATCH 3/3] bond: service netpoll arp queue on master device
Date: Sun, 27 Feb 2011 16:12:25 -0800 (PST)
Message-ID: <20110227.161225.200373200.davem@davemloft.net>
References: <1298022215-21059-1-git-send-email-amwang@redhat.com>
	<1298022215-21059-3-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, nhorman@redhat.com,
	herbert@gondor.hengli.com.au, nhorman@tuxdriver.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298022215-21059-3-git-send-email-amwang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amerigo Wang <amwang@redhat.com>
Date: Fri, 18 Feb 2011 17:43:34 +0800

> Neil pointed out that we can't send ARP reply on behalf of slaves,
> we need to move the arp queue to their bond device.
> 
> Signed-off-by: WANG Cong <amwang@redhat.com>

Applied.
