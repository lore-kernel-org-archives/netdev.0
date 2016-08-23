From: Mikko Rapeli <mikko.rapeli@iki.fi>
Subject: Re: [PATCH v05 66/72] uapi icmp.h: glibc netinet/ip_icmp.h header
 file compatibility fixes
Date: Wed, 24 Aug 2016 00:21:45 +0300
Message-ID: <20160823212145.GW5399@lakka.kapsi.fi>
References: <20160822.163251.1904761519827702046.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, edumazet@google.com,
        nicolas.dichtel@6wind.com, ralf@linux-mips.org,
        linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160822.163251.1904761519827702046.davem@davemloft.net>
 <20160822.163322.904817610242858006.davem@davemloft.net>
 <20160822.163328.128299200974687538.davem@davemloft.net>
 <20160822.163303.1956681667227236700.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 22, 2016 at 04:32:51PM -0700, David Miller wrote:
> You have to post this properly to the netdev list.
> 
> If netdev is not CC:'d it doesn't get properly logged in patchwork,
> and won't be applied.

Sorry, get_maintainers.pl did not find netdev list for these patches.

Could you update MAINTAINERS so that networking stuff from include/linux/uapi/
finds netdev?

I could propose patches but they are bound to be incomplete so networking devs
could do this faster and with fewer review iterations.

This problem seems to be quite common though. Maybe the uapi split did not
update MAINTAINER file with include/uapi files.

-Mikko
