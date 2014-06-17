From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: tile: fix unused variable warning
Date: Mon, 16 Jun 2014 21:34:27 -0700 (PDT)
Message-ID: <20140616.213427.126923556571858602.davem@davemloft.net>
References: <201406161816.s5GIGptF028053@farm-0039.internal.tilera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sergei.shtylyov@cogentembedded.com, tklauser@distanz.ch
To: cmetcalf@tilera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201406161816.s5GIGptF028053@farm-0039.internal.tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Metcalf <cmetcalf@tilera.com>
Date: Mon, 16 Jun 2014 13:14:05 -0400

> 'i' is unused in tile_net_dev_init() after commit d581ebf5a1f
> ("net: tile: Use helpers from linux/etherdevice.h to check/set MAC").
> 
> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
> ---
> v2: includes previous commit's summary line as suggested by Sergei Shtylyov.

Applied, thanks.
