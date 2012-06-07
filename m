From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v10] tilegx network driver: initial support
Date: Thu, 07 Jun 2012 13:52:53 -0700
Message-ID: <1339102373.14838.18.camel@joe2Laptop>
References: <201206042023.q54KNEZp003834@farm-0002.internal.tilera.com>
	 <1339004459.26966.31.camel@edumazet-glaptop> <4FCFA312.4020505@tilera.com>
	 <20120606.115440.1245419453265419850.davem@davemloft.net>
	 <201206072031.q57KV0NG029301@farm-0023.internal.tilera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, arnd@arndb.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Chris Metcalf <cmetcalf@tilera.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201206072031.q57KV0NG029301@farm-0023.internal.tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-04-06 at 16:42 -0400, Chris Metcalf wrote:
> This change adds support for the tilegx network driver based on the
> GXIO IORPC support in the tilegx software stack, using the on-chip
> mPIPE packet processing engine.
> 
> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
> ---
> This version makes the driver multi-queued and support non-zero
> tx_queue_len.  I also made a couple of magic numbers into #defines.
> I skimmed the tg3.c driver, but didn't see any other obvious
> changes that would be appropriate.
> 

Hi Chris.

Can you please use git send-email instead of
generating odd header dates like April 6, 2012
and Sept 16, 2001?

git send-email will use your system date.
