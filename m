From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][2.5.22] OOPS in tcp_v6_get_port
Date: Mon, 17 Jun 2002 19:17:26 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <aem5pf$sj7$2@main.gmane.org>
References: <Pine.LNX.4.44.0206171314460.2496-300000@lain.perlfu.co.uk>
	<20020617.143319.54623892.davem@redhat.com>
	<20020618005735.GB1146@conectiva.com.br>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: critson@perlfu.co.uk, torvalds@transmeta.com, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: acme@conectiva.com.br
In-Reply-To: <20020618005735.GB1146@conectiva.com.br>
List-Id: netdev.vger.kernel.org

   From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
   Date: Mon, 17 Jun 2002 21:57:35 -0300

   --- orig/net/ipv6/tcp_ipv6.c	Sat May 25 23:13:56 2002
   +++ linux/net/ipv6/tcp_ipv6.c	Fri Jun 14 23:23:07 2002

I've installed this change into my tree in the meantime.
If we find a better fix, we can just revert this.

Thanks.
