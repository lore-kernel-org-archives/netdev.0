From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2.6] CBQ: Destroy filters before destroying classes
Date: Wed, 20 Oct 2004 08:40:05 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020064004.GC21977@postel.suug.ch>
References: <20041007175313.GA19628@postel.suug.ch> <20041019213906.2aced91d.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041019213906.2aced91d.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* David S. Miller <20041019213906.2aced91d.davem@davemloft.net> 2004-10-19 21:39
> BTW, that patch set forgot to handle sch_atm.c, I'm beginning to
> believe that I'm the only developer with this packet scheduler
> enabled in his test builds :-)  Most people don't have it enabled
> because it requires CONFIG_ATM to be on.

My apologies and thanks for fixing it. I have put it on now :->
I will submit patches to convert the class part of classful qdiscs
later today.
