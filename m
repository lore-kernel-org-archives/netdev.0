From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH] (8/17) ipx -- size_t for send/recvmsg
Date: Thu, 8 Jan 2004 20:17:51 -0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040108221751.GC3062@conectiva.com.br>
References: <20040109140223.3926cbeb@linux.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040109140223.3926cbeb@linux.local>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Fri, Jan 09, 2004 at 02:02:23PM -0800, Stephen Hemminger escreveu:
> Convert IPX to unsigned for send/receive message length.
> Enforce MTU limited by header pktsize.

ACK, thanks Stephen.
