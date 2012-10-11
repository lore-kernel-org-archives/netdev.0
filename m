From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next? V2] pktgen: Use simpler test for non-zero
 ipv6 address
Date: Thu, 11 Oct 2012 15:20:57 -0400 (EDT)
Message-ID: <20121011.152057.418629873945363485.davem@davemloft.net>
References: <1349894559.2035.12.camel@joe-AO722>
	<1349895710.21172.7235.camel@edumazet-glaptop>
	<1349897005.2035.24.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, brian.haley@hp.com
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1349897005.2035.24.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 10 Oct 2012 12:23:25 -0700

> Reduces object size and should be slightly faster.
> 
> allyesconfig: 
> $ size net/core/pktgen.o*
>    text	   data	    bss	    dec	    hex	filename
>   52284	   4321	  11840	  68445	  10b5d	net/core/pktgen.o.new
>   52310	   4293	  11848	  68451	  10b63	net/core/pktgen.o.old
>  
> Signed-off-by: Joe Perches <joe@perches.com>

Please resubmit when net-next opens.
