From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169: panic on 2.6.11
Date: Fri, 4 Mar 2005 22:39:11 +0100
Message-ID: <20050304213911.GA1148@electric-eye.fr.zoreil.com>
References: <20050304132804.270cf05b@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050304132804.270cf05b@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> :
> I was intentionally over stressing r8169 without NAPI to test out
> an alternative version of netif_rx, and discovered the following bug.
> Looks like a problem in r8169. I was using pktgen to overwhelm the r8169
> from a fast machine.

Thanks. I'm on it.

--
Ueimor
