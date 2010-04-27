From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] RCU: don't turn off lockdep when find suspicious
 rcu_dereference_check() usage
Date: Tue, 27 Apr 2010 16:52:55 -0700
Message-ID: <20100427235255.GH2424@linux.vnet.ibm.com>
References: <20100427162201.GA5826@linux.vnet.ibm.com>
 <g2ya44ae5cd1004271058p9f73fba1v3f611693e81869c3@mail.gmail.com>
 <20100427233111.GF2424@linux.vnet.ibm.com>
 <20100427.164239.73369551.davem@davemloft.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: miles.lane@gmail.com, ebiederm@xmission.com, vgoyal@redhat.com,
	eparis@redhat.com, laijs@cn.fujitsu.com, mingo@elte.hu,
	peterz@infradead.org, linux-kernel@vger.kernel.org,
	nauman@google.com, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	jens.axboe@oracle.com, guijianfeng@cn.fujitsu.com,
	lizf@cn.fujitsu.com, johannes@sipsolutions.net
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100427.164239.73369551.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 27, 2010 at 04:42:39PM -0700, David Miller wrote:
> From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
> Date: Tue, 27 Apr 2010 16:31:11 -0700
> 
> > Thank you both!  I have added Eric's Acked-by and Miles's Tested-by.
> 
> How can you?  It's in net-next-2.6 already :-)

OK, OK, I will drop my copy.  ;-)

							Thanx, Paul
