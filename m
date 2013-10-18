From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] fib_trie: remove duplicated rcu lock
Date: Fri, 18 Oct 2013 13:54:27 -0400 (EDT)
Message-ID: <20131018.135427.1167985246850003150.davem@davemloft.net>
References: <1381636737.3392.29.camel@edumazet-glaptop.roam.corp.google.com>
	<1381665009-4436-1-git-send-email-baker.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: baker.kernel@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1381665009-4436-1-git-send-email-baker.kernel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: baker.kernel@gmail.com
Date: Sun, 13 Oct 2013 19:50:09 +0800

> From: "baker.zhang" <baker.kernel@gmail.com>
> 
> fib_table_lookup has included the rcu lock protection.
> 
> Signed-off-by: baker.zhang <baker.kernel@gmail.com>

Applied, thanks.
