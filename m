From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bonding driver has bad load balancing for forwarded traffic,
 3.7+
Date: Thu, 18 Apr 2013 12:33:08 -0700
Message-ID: <1366313588.3205.76.camel@edumazet-glaptop>
References: <516C075E.30105@telenet.dn.ua>
	 <1366072679.4459.113.camel@edumazet-glaptop>
	 <1366081404.4459.127.camel@edumazet-glaptop>
	 <20130418.150910.1780951630545456624.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: vitalyb@telenet.dn.ua, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, fubar@us.ibm.com, linux@8192.net
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130418.150910.1780951630545456624.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-04-18 at 15:09 -0400, David Miller wrote:

> Applied and queued up for -stable, but:
> 
> > +						sizeof(_l4), &_l4);						
>                                                                    ^^^^^^^^^^^^^^^^^^^^^^^^^
> 
> That's some rather amazing trailing whitespace.  Are you trying to break
> free of earth's atmosphere? :-)

Ah, sorry for this ;)

Thanks
