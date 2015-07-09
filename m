From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] net: pktgen: fix race between
 pktgen_thread_worker() and kthread_stop()
Date: Thu, 09 Jul 2015 15:06:10 -0700 (PDT)
Message-ID: <20150709.150610.1320631571607151185.davem@davemloft.net>
References: <20150708194154.GA26534@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, edumazet@google.com, jstancek@redhat.com,
	mleitner@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: oleg@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150708194154.GA26534@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Oleg Nesterov <oleg@redhat.com>
Date: Wed, 8 Jul 2015 21:41:54 +0200

> I am not familiar with this code and I have no idea how to test
> these changes, so 2/2 comes as a separate change. 1/2 looks like
> the obvious bugfix, and probably candidate for -stable.

These look fine to me, applied and patch #1 queued up for -stable.

Thanks.
