From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] vlan: fix misunderstanding at struct packet_type
 initialization
Date: Tue, 29 Apr 2003 00:00:53 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030429.000053.102551564.davem@redhat.com>
References: <20030429080142.GS25361@conectiva.com.br>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: acme@conectiva.com.br
In-Reply-To: <20030429080142.GS25361@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


VLAN understands shared SKBs Arnaldo. :-)

See vlan_skb_recv() and vlan_check_reorder_header().
