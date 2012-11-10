From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 8/7] pppoatm: fix missing wakeup in pppoatm_send()
Date: Sat, 10 Nov 2012 13:38:10 -0500 (EST)
Message-ID: <20121110.133810.754496966938629729.davem@davemloft.net>
References: <1352292734.7340.35.camel@shinybook.infradead.org>
	<20121109.163012.719663130136182296.davem@davemloft.net>
	<1352532973.9449.105.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krzysiek@podlesie.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, chas@cmf.nrl.navy.mil
To: dwmw2@infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1352532973.9449.105.camel@shinybook.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Woodhouse <dwmw2@infradead.org>
Date: Sat, 10 Nov 2012 07:36:13 +0000

> I was hoping for an ack from Chas and/or Krzysztof, especially as I
> hadn't tested my patch. So hopefully there'll be a v4 series of 8
> patches, including this one... and all from the same person, which
> makes it slightly easier to follow :)

Ok, great.
