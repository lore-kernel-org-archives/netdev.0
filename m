From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCHES] IPVS - use list_for_each_entry_continue, fix NQ
Date: Tue, 30 Sep 2003 12:22:47 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309301214430.2555-100000@l>
References: <20030930015659.3cc375b1.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: wensong@linux-vs.org, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030930015659.3cc375b1.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Tue, 30 Sep 2003, David S. Miller wrote:

> > list_for_each_entry_continue and use it for some IPVS schedulers. There is
> > also a NQ scheduler fix. Please consider for inclusion.
>
> Looks good, applied.  Can you please CC: netdev@oss.sgi.com on all
> patch submissions, even small and obvious ones?  Thanks.

	Always :)

> I assume you guys are still reviewing Rusty's skb_linearize()
> removal patch?

	Yes, we will synchronize with Wensong to avoid double work.
As for me, I like 90% of the changes and started to import them in
my tree, I hope we will be back at the end of this week.

Regards

--
Julian Anastasov <ja@ssi.bg>
