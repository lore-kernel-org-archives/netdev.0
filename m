From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH v2] net: don't allow CAP_NET_ADMIN to load non-netdev
 kernel modules
Date: Thu, 10 Mar 2011 09:53:52 +1100 (EST)
Message-ID: <alpine.LRH.2.00.1103100953330.4485@tundra.namei.org>
References: <20110301213313.GA6507@albatros> <4D6DEE7C.6020700@msgid.tls.msk.ru> <20110309220633.GA14750@albatros> <20110309.140928.70185544.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: segoon@openwall.com, mjt@tls.msk.ru, linux-kernel@vger.kernel.org,
	arnd@arndb.de, mirqus@gmail.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	yoshfuji@linux-ipv6.org, kaber@trash.net, eric.dumazet@gmail.com,
	therbert@google.com, xiaosuo@gmail.com, jesse@nicira.com,
	kees.cook@canonical.com, eugene@redhat.com,
	dan.j.rosenberg@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110309.140928.70185544.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 9 Mar 2011, David Miller wrote:

> I was hoping someone other than me would take this upstream, feel free
> to submit it directly to Linus with my ack:
> 
> Acked-by: David S. Miller <davem@davemloft.net>

I can submit it via my tree.

-- 
James Morris
<jmorris@namei.org>
