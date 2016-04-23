From: Alexander Aring <aar@pengutronix.de>
Subject: Re: [PATCH net-next 2/9] libnl: nla_put_le64(): align on a 64-bit
 area
Date: Sat, 23 Apr 2016 19:28:28 +0200
Message-ID: <9d534571-916d-b368-a398-7f03a1f512ec@pengutronix.de>
References: <1461339084-3849-1-git-send-email-nicolas.dichtel@6wind.com>
 <1461339084-3849-3-git-send-email-nicolas.dichtel@6wind.com>
 <1461343880.7627.34.camel@edumazet-glaptop3.roam.corp.google.com>
 <60b94d1a-23a2-ec18-7f2b-2ba21946af03@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, linux-wpan@vger.kernel.org,
	pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	pshelar@nicira.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, netfilter-devel@vger.kernel.org,
	dev@openvswitch.org, steffen.klassert@secunet.com,
	herbert@gondor.apana.org.au, bsingharora@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <60b94d1a-23a2-ec18-7f2b-2ba21946af03@pengutronix.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

On 04/23/2016 07:05 PM, Alexander Aring wrote:
...
> 
> if this is really needed, then nla_put_u64/be64/etc need to be changed also,

Okay, I found PATCH 3/9 do it for be64, but what's about u64?

- Alex
