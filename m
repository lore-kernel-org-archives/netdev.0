From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: linux-next: Tree for Dec 31 (net/xfrm/xfrm_input.c)
Date: Thu, 31 Dec 2015 11:05:33 -0800
Message-ID: <56857C7D.6010909@infradead.org>
References: <20151231233008.41fc8451@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20151231233008.41fc8451@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/31/15 04:30, Stephen Rothwell wrote:
> Hi all,
> 
> Changes since 20151223:
> 


seen on i386 or x86_64:

In file included from ../net/xfrm/xfrm_input.c:17:0:
../include/net/ip6_tunnel.h: In function 'ip6tunnel_xmit':
../include/net/ip6_tunnel.h:93:2: error: implicit declaration of function 'iptunnel_xmit_stats' [-Werror=implicit-function-declaration]
  iptunnel_xmit_stats(dev, pkt_len);
  ^



-- 
~Randy
