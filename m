From: Arthur Kepner <akepner@sgi.com>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Tue, 17 May 2005 13:21:13 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0505171308220.29021@linux.site>
References: <Pine.LNX.4.61.0505170914130.29021@linux.site>
 <20050517.104947.112621738.davem@davemloft.net> <Pine.LNX.4.61.0505171104030.29021@linux.site>
 <20050517.114829.115910656.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S.Miller" <davem@davemloft.net>
In-Reply-To: <20050517.114829.115910656.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Tue, 17 May 2005, David S.Miller wrote:

> ....
> Can I tell users to call you when they enable the strict
> fragmentation and they can no longer talk UDP to
> remote sites outside of their subnet, or it breaks
> on their heavily SMP machine due to natural system local
> packet reordering?
> ....

I'd much rather take that call than one from a customer 
whose data has been quietly corrupted.

--
Arthur
