From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [RFC/PATCH] remove unneeded check in bcm43xx
Date: Wed, 12 Apr 2006 08:21:17 +1000
Message-ID: <1144794077.19353.53.camel@localhost.localdomain>
References: <1144719972.19353.24.camel@localhost.localdomain>
	 <20060410.224933.39567033.davem@davemloft.net>
	 <1144788541.19353.41.camel@localhost.localdomain>
	 <20060411.143407.74615246.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: benoit.boissinot@ens-lyon.org, mb@bu3sch.de,
	netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de,
	linux-kernel@vger.kernel.org, linville@tuxdriver.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751167AbWDKWVn@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060411.143407.74615246.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> I still think we shouldn't reward shit hardware by complicating
> up our DMA mappings internals. :-)

BTW. In the meantime, can't that driver work in PIO only mode ?

Ben.
