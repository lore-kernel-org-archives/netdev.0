From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ppp: remove some pointless conditionals before
 kfree_skb()
Date: Thu, 26 Feb 2009 23:08:03 -0800 (PST)
Message-ID: <20090226.230803.51086676.davem@davemloft.net>
References: <49A51A68.3000509@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, jgarzik@pobox.com, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org
To: yjwei@cn.fujitsu.com
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <49A51A68.3000509@cn.fujitsu.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Wed, 25 Feb 2009 18:16:08 +0800

> Remove some pointless conditionals before kfree_skb().
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Applied.
