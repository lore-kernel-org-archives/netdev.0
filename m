From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: fix bond-6-mode change MAC of arp reply from
 vif to cause Domu's network unreachable intermittently
Date: Mon, 29 Oct 2012 13:33:38 -0400 (EDT)
Message-ID: <20121029.133338.1308520640627047074.davem@davemloft.net>
References: <508E4840.40104@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	linux-kernel@vger.kernel.org, joe.jin@oracle.com
To: zheng.x.li@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <508E4840.40104@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "zheng.li" <zheng.x.li@oracle.com>
Date: Mon, 29 Oct 2012 17:11:28 +0800

> @@ -700,7 +700,18 @@ static struct slave *rlb_arp_xmit(struct sk_buff
> *skb, struct bonding *bond)

You commit message is poorly formatted and your email client corrupted
the patch, making it completely unusable.
