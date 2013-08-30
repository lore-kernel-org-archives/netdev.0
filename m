From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] drivers:net: Convert
 dma_alloc_coherent(...__GFP_ZERO) to dma_zalloc_coherent
Date: Thu, 29 Aug 2013 21:14:32 -0700
Message-ID: <1377836072.1928.137.camel@joe-AO722>
References: <dbbfc5e66dba7d2b63549d218407fb0c4031f2ed.1363367992.git.joe@perches.com>
	 <1377582323.2658.10.camel@joe-AO722>
	 <20130829.220926.226210132086755040.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, linux-wireless@vger.kernel.org,
	b43-dev@lists.infradead.org, users@rt2x00.serialmonkey.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130829.220926.226210132086755040.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-08-29 at 22:09 -0400, David Miller wrote:
> Applied, thanks a lot Joe.

Too bad I didn't know there was a dma_zalloc_coherent
the first time...

cheers, Joe
