From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] RCU: don't turn off lockdep when find suspicious
 rcu_dereference_check() usage
Date: Tue, 27 Apr 2010 16:42:39 -0700 (PDT)
Message-ID: <20100427.164239.73369551.davem@davemloft.net>
References: <20100427162201.GA5826@linux.vnet.ibm.com>
	<g2ya44ae5cd1004271058p9f73fba1v3f611693e81869c3@mail.gmail.com>
	<20100427233111.GF2424@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: miles.lane@gmail.com, ebiederm@xmission.com, vgoyal@redhat.com,
	eparis@redhat.com, laijs@cn.fujitsu.com, mingo@elte.hu,
	peterz@infradead.org, linux-kernel@vger.kernel.org,
	nauman@google.com, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	jens.axboe@oracle.com, guijianfeng@cn.fujitsu.com,
	lizf@cn.fujitsu.com, johannes@sipsolutions.net
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100427233111.GF2424@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Tue, 27 Apr 2010 16:31:11 -0700

> Thank you both!  I have added Eric's Acked-by and Miles's Tested-by.

How can you?  It's in net-next-2.6 already :-)
