From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] inet: Add skb_copy_datagram_iter
Date: Mon, 10 Nov 2014 11:18:50 -0500 (EST)
Message-ID: <20141110.111850.103241671429881179.davem@davemloft.net>
References: <20141110065817.GG7996@ZenIV.linux.org.uk>
	<20141110.023000.1275181784917275552.davem@davemloft.net>
	<20141110090955.GH7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bcrl@kvack.org, mst@redhat.com
To: viro@ZenIV.linux.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141110090955.GH7996@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Mon, 10 Nov 2014 09:09:55 +0000

> BTW, what's the usual regression suite used for net/* stuff?

There's a regression suite? :-)
