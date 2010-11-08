From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_unix: unix_write_space() use keyed wakeups
Date: Mon, 08 Nov 2010 13:44:17 -0800 (PST)
Message-ID: <20101108.134417.35041051.davem@davemloft.net>
References: <1288380431.2680.3.camel@edumazet-laptop>
	<1288421084.2680.717.camel@edumazet-laptop>
	<alpine.DEB.2.00.1010300759580.9195@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, alban.crequy@collabora.co.uk,
	shemminger@vyatta.com, gorcunov@openvz.org, adobriyan@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pauli.nieminen@collabora.co.uk, rweikusat@mssgmbh.com
To: davidel@xmailserver.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1010300759580.9195@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Davide Libenzi <davidel@xmailserver.org>
Date: Sat, 30 Oct 2010 08:03:15 -0700 (PDT)

> On Sat, 30 Oct 2010, Eric Dumazet wrote:
> 
>> This patch is a specialization of commit 37e5540b3c9d (epoll keyed
>> wakeups: make sockets use keyed wakeups).
> 
> Whoops, I must have missed AF_UNIX :)
> Looks good to me.

Applied.
