From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix inverted test in __skb_recv_datagram
Date: Mon, 07 Dec 2015 22:28:27 -0500 (EST)
Message-ID: <20151207.222827.1680789119862020474.davem@davemloft.net>
References: <20151206.233038.1580536748391971635.davem@davemloft.net>
	<874mft7sur.fsf_-_@doppelsaurus.mobileactivedefense.com>
	<87vb8925vx.fsf_-_@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: rweikusat@mobileactivedefense.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87vb8925vx.fsf_-_@doppelsaurus.mobileactivedefense.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Date: Mon, 07 Dec 2015 23:30:58 +0000

> As the kernel generally uses negated error numbers, *err needs to be
> compared with -EAGAIN (d'oh).
> 
> Signed-off-by: Rainer Weikusat <rweikusat@mobileactivedefense.com>
> Fixes: ea3793ee29d3

Improperly formatted Fixes: tag, you must also include the commit
header line, in parenthesis and double quotes, after the SHA_ID.

Futhermore this is the wrong SHA_ID.
