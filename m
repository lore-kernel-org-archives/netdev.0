From: "David S. Miller" <davem@davemloft.net>
Subject: Re: tg3 crashes in scatter gather mode
Date: Mon, 16 May 2005 23:53:21 -0700 (PDT)
Message-ID: <20050516.235321.41634951.davem@davemloft.net>
References: <1116311948.3021.7.camel@raz-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: razb@bitband.com
In-Reply-To: <1116311948.3021.7.camel@raz-laptop>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: raz ben jehuda <razb@bitband.com>
Date: Tue, 17 May 2005 09:39:08 +0300

> I have written a fast udp stack that implements a real scatter gather
> over user space pages. When i use it over an Intel e1000 card every
> thing works fine.  doing the same thing over the tg3 crashes the system
> somewhere in tg3_poll area. 
> Anyone ?

How about posting your code so we can have some hope
of analyzing your bug report?
