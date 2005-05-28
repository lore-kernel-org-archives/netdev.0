From: Thomas Graf <tgraf@suug.ch>
Subject: Re: PATCH: rtnetlink explicit flags setting
Date: Sat, 28 May 2005 14:18:27 +0200
Message-ID: <20050528121827.GQ15391@postel.suug.ch>
References: <20050527125010.GO15391@postel.suug.ch> <1117202331.6383.39.camel@localhost.localdomain> <20050527141320.GQ15391@postel.suug.ch> <1117206091.6383.73.camel@localhost.localdomain> <20050527151913.GA15391@postel.suug.ch> <1117209466.6383.106.camel@localhost.localdomain> <20050527165935.GC15391@postel.suug.ch> <1117242749.6251.15.camel@localhost.localdomain> <20050528012810.GN15391@postel.suug.ch> <1117244893.6251.41.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1117244893.6251.41.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1117244893.6251.41.camel@localhost.localdomain> 2005-05-27 21:48
> I did check netfilter, net/sched/ tcp_diag, xfrm and they do things
> right.

OK.

> Hrm - you should probably have said that in the patch text ;-> 

I wanted to have some time for testing today without the need
to resubmit the patches. ;->

> I did test the one i sent - basic things and by code inspection saw
> little risk as well. Perhaps we should push mine then you can add on top
> of it.

I just tested both patches for about 30 minutes. Everything OK. Feel
free to apply the patches.
