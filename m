From: Eric Lemoine <Eric.Lemoine@Sun.COM>
Subject: Re: simple change to qdisc_restart()
Date: Mon, 26 May 2003 11:15:19 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030526091519.GD343@udine>
References: <20030520082217.GC978@udine>
 <20030520.012824.85398613.davem@redhat.com> <20030520085724.GD978@udine>
 <16074.1339.3673.938923@robur.slu.se> <20030520112109.GE978@udine>
 <16074.7787.988583.56689@robur.slu.se> <20030520083020.N40924@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-reply-to: <20030520083020.N40924@shell.cyberus.ca>
To: Jamal Hadi <hadi@shell.cyberus.ca>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> His patch should be interesting. I have seen NICs showing up in the market
> with multiple DMA rings/channels and you can map flows to channels.
> Locking the device on egress just because one of the rings is full doesnt
> make sense. Such boards maybe the perfect pktgen board for you, btw ;->
> Can you post your patch Eric?

I'm working on being authorized to give out my code. It may take some
time...

-- 
Eric
