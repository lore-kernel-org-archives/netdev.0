From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inet: Clean up inet_csk_wait_for_connect() vs.
 might_sleep()
Date: Mon, 16 Mar 2015 17:12:43 -0400 (EDT)
Message-ID: <20150316.171243.1969465707208233939.davem@davemloft.net>
References: <1426533564.11398.229.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peterz@infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426533564.11398.229.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 16 Mar 2015 12:19:24 -0700

> In commit 26cabd31259ba43f68026ce3f62b78094124333f
> Peter added a sched_annotate_sleep() in sk_wait_event()
> 
> Is the following patch needed as well ?

Who is asking this question and who is it directed at?

It looks like something that needs to be resolved before I apply this
patch, right?
