From: Kees Cook <kees.cook@canonical.com>
Subject: Re: [PATCH v2] net: don't allow CAP_NET_ADMIN to load non-netdev
 kernel modules
Date: Wed, 2 Mar 2011 08:01:52 -0800
Message-ID: <20110302160152.GQ4669@outflux.net>
References: <201102272122.52643.arnd@arndb.de>
 <4D6B6AE7.2050202@msgid.tls.msk.ru>
 <20110228095133.GA4351@albatros>
 <20110228.112349.104067277.davem@davemloft.net>
 <20110301194845.GA3533@albatros>
 <1299010390.2529.30.camel@bwh-desktop>
 <20110301213313.GA6507@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, mjt@tls.msk.ru, arnd@arndb.de,
	mirqus@gmail.com, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, eric.dumazet@gmail.com, therbert@google.com,
	xiaosuo@gmail.com, jesse@nicira.com, eugene@redhat.com,
	dan.j.rosenberg@gmail.com, akpm@linux-foundation.org
To: Vasiliy Kulikov <segoon@openwall.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110301213313.GA6507@albatros>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 02, 2011 at 12:33:13AM +0300, Vasiliy Kulikov wrote:
> This patch restricts an ability of autoloading modules to netdev modules
> with explicit aliases.  This fixes CVE-2011-1019.
> ...
> Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>

Looks good; thanks for sorting this out.

Acked-by: Kees Cook <kees.cook@canonical.com>

-Kees

-- 
Kees Cook
Ubuntu Security Team
