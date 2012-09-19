From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2 7/9] net/macb: ethtool interface: add register dump
 feature
Date: Wed, 19 Sep 2012 16:14:02 +0100
Message-ID: <1348067642.4836.58.camel@deadeye.wl.decadent.org.uk>
References: <cover.1348055112.git.nicolas.ferre@atmel.com>
	 <20ebfb29f6f4a84d8ba20553e2d81cd456f438de.1348055112.git.nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<havard@skinnemoen.net>, <linux-arm-kernel@lists.infradead.org>,
	<plagnioj@jcrosoft.com>, <patrice.vilchez@atmel.com>,
	<linux-kernel@vger.kernel.org>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20ebfb29f6f4a84d8ba20553e2d81cd456f438de.1348055112.git.nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-09-19 at 13:55 +0200, Nicolas Ferre wrote:
> Add macb_get_regs() ethtool function and its helper function:
> macb_get_regs_len().
> The version field is deduced from the IP revision which gives the
> "MACB or GEM" information. An additional version field is reserved.
> 
> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
> Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>
[...]

Please also send the register dump decoder for the ethtool utility once
this series is accepted.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
