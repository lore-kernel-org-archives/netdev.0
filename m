From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH][IPV6] compile fix for net/ipv6/route.c in current bk
Date: Sun, 18 May 2003 00:02:31 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030518030230.GN20240@conectiva.com.br>
References: <Mutt.LNX.4.44.0305181227260.21143-100000@excalibur.intercode.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>,
   "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>,
   kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@intercode.com.au>
Content-Disposition: inline
In-Reply-To: <Mutt.LNX.4.44.0305181227260.21143-100000@excalibur.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Sun, May 18, 2003 at 12:29:53PM +1000, James Morris escreveu:
> This version of the ip6_null_entry initializer is needed for complation to 
> succeed with gcc version 2.96 20000731 (Red Hat Linux 7.3 2.96-110).

Already in davem's tree and submitted to Linus 8)

- Arnaldo
