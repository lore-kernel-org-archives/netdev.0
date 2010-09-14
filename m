From: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [rds-devel] net-next pull request: RDS
Date: Tue, 14 Sep 2010 16:10:37 -0700
Message-ID: <ada62y7x6oi.fsf@cisco.com>
References: <4C892C9C.4060304@oracle.com> <4C8C9422.2070306@Voltaire.com>
	<20100914183514.GA3417@takashi.pdx.zabbo.net>
	<AANLkTin69m0kK6bqUiwYeHRQT0Ehso16xA6RBtBFFgW3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zach Brown <zach.brown-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	Or Gerlitz <ogerlitz-smomgflXvOZWk0Htik3J/w@public.gmane.org>,
	Andy Grover <andy.grover-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	RDS Devel <rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org>
To: Andrew Grover <andy.grover-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AANLkTin69m0kK6bqUiwYeHRQT0Ehso16xA6RBtBFFgW3-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Andrew Grover's message of "Tue, 14 Sep 2010 15:28:00 -0700")
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

 > Since rds goes upstream via netdev not linux-rdma, it's a little
 > tricky.. any core ib helpers we added would not be in net-next so rds
 > wouldn't build. :) Once net-next gets pushed to mainline and Roland
 > pulls from that, then we'll be in a good position to put these helpers
 > where they should go, and change other ULPs to use them.

In cases where cross-tree dependencies exist, I'm happy to review core
IB stack changes but then have them go upstream via davem after
linux-rdma is happy with them.

 - R.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
