From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: 3.6-rt: inet_sk_rx_dst_set() network splat
Date: Fri, 3 May 2013 10:20:58 +0200
Message-ID: <20130503082058.GA8230@linutronix.de>
References: <1366786204.5977.10.camel@marge.simpson.net>
 <1366853695.8964.120.camel@edumazet-glaptop>
 <1366865490.4595.22.camel@marge.simpson.net>
 <1366866233.8964.128.camel@edumazet-glaptop>
 <20130426105030.GE20927@linutronix.de>
 <1367455779.30667.113.camel@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Mike Galbraith <bitbucket@online.de>,
	David Miller <davem@davemloft.net>,
	RT <linux-rt-users@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-rt-users-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1367455779.30667.113.camel@gandalf.local.home>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Steven Rostedt | 2013-05-01 20:49:39 [-0400]:

>Is this something going into the stable tree, or does it not affect 3.0,
>3.2, 3.4 or 3.6?

Mike Galbraith reported it against v3.6 so I would say that this is one
candidate. I just booted v3.4.41-rt55 and it runs for 20 minutes now
without any issues. Maybe it crashes after I sent the email but I hope
it does not :)

>-- Steve

Sebastian
