From: "David S. Miller" <davem@redhat.com>
Subject: Re: 2.6.7-bk6 fails module compile -- iptable_raw.c
Date: Wed, 23 Jun 2004 08:00:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040623080027.09457b66.davem@redhat.com>
References: <200406231256.IAA28505@clem.clem-digital.net>
	<20040623.224203.122414746.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: clem@clem.clem-digital.net, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040623.224203.122414746.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 23 Jun 2004 22:42:03 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> > net/ipv4/netfilter/iptable_raw.c:57: unknown field `target_size' specified in initializer
 ...
> Please try this.
> 
> ===== net/ipv4/netfilter/iptable_raw.c 1.2 vs edited =====
> --- 1.2/net/ipv4/netfilter/iptable_raw.c	2004-06-22 06:39:19 +09:00
> +++ edited/net/ipv4/netfilter/iptable_raw.c	2004-06-23 22:35:44 +09:00

Applied, thanks.
