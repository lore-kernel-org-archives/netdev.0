From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] RCU: don't turn off lockdep when find suspicious
 rcu_dereference_check() usage
Date: Sun, 25 Apr 2010 00:49:25 -0700 (PDT)
Message-ID: <20100425.004925.54203352.davem@davemloft.net>
References: <m2xa44ae5cd1004231559hcf90671asf146a43b4748c2c3@mail.gmail.com>
	<20100425023455.GM2440@linux.vnet.ibm.com>
	<1272181534.3614.1.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, miles.lane@gmail.com,
	vgoyal@redhat.com, eparis@redhat.com, laijs@cn.fujitsu.com,
	mingo@elte.hu, peterz@infradead.org, linux-kernel@vger.kernel.org,
	nauman@google.com, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	jens.axboe@oracle.com, guijianfeng@cn.fujitsu.com,
	lizf@cn.fujitsu.com
To: johannes@sipsolutions.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1272181534.3614.1.camel@jlt3.sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes@sipsolutions.net>
Date: Sun, 25 Apr 2010 09:45:34 +0200

> The station locking is a tad confusing, but I've added the right
> annotations already, should be coming to a kernel near you soon (i.e.
> are in net-2.6 right now).

Linus took in everything I have so it should be in Linus's tree
by now.
