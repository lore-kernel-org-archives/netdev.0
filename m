From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH] vlan: fix misunderstanding at struct packet_type initialization
Date: Tue, 29 Apr 2003 05:10:18 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030429081018.GT25361@conectiva.com.br>
References: <20030429080142.GS25361@conectiva.com.br> <20030429.000053.102551564.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030429.000053.102551564.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Tue, Apr 29, 2003 at 12:00:53AM -0700, David S. Miller escreveu:
> 
> VLAN understands shared SKBs Arnaldo. :-)
> 
> See vlan_skb_recv() and vlan_check_reorder_header().

Oh well, so the comment has to be changed 8)

- Arnaldo
