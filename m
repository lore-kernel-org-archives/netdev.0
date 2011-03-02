From: Jake Edge <jake@lwn.net>
Subject: Re: [PATCH v2] net: don't allow CAP_NET_ADMIN to load non-netdev
 kernel modules
Date: Wed, 2 Mar 2011 13:40:06 -0700
Message-ID: <20110302134006.2a2e7c61@chukar>
References: <201102272122.52643.arnd@arndb.de>
	<4D6B6AE7.2050202@msgid.tls.msk.ru>
	<20110228095133.GA4351@albatros>
	<20110228.112349.104067277.davem@davemloft.net>
	<20110301194845.GA3533@albatros>
	<1299010390.2529.30.camel@bwh-desktop>
	<20110301213313.GA6507@albatros>
	<m34o7ltipi.fsf@lwn.net>
	<20110302194354.GA31043@albatros>
	<20110302124936.289a1915@chukar>
	<20110302201807.GA31965@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, mjt@tls.msk.ru, arnd@arndb.de,
	mirqus@gmail.com, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, eric.dumazet@gmail.com, therbert@google.com,
	xiaosuo@gmail.com, jesse@nicira.com, kees.cook@canonical.com,
	eugene@redhat.com, dan.j.rosenberg@gmail.com,
	akpm@linux-foundation.org
To: Vasiliy Kulikov <segoon@openwall.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110302201807.GA31965@albatros>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2 Mar 2011 23:18:07 +0300 Vasiliy Kulikov wrote:

> As root has CAP_NET_ADMIN, the alias netdev-gre0 is tried and it
> succeeds.

Never mind, my apologies for the noise ... one always reads replies
most carefully just *after* hitting send ...

jake

-- 
Jake Edge - LWN - jake@lwn.net - http://lwn.net
