From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/1] net/hyperv: Add flow control based on hi/low
 watermark
Date: Wed, 28 Mar 2012 19:05:00 +0100
Message-ID: <1332957900.2624.38.camel@bwh-desktop.uk.solarflarecom.com>
References: <1332800304-5060-1-git-send-email-haiyangz@microsoft.com>
	 <1332800304-5060-2-git-send-email-haiyangz@microsoft.com>
	 <20120326231017.GA30684@kroah.com>
	 <20120326.191237.2192763107267474232.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <gregkh@linuxfoundation.org>, <haiyangz@microsoft.com>,
	<netdev@vger.kernel.org>, <devel@linuxdriverproject.org>,
	<olaf@aepfle.de>, <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120326.191237.2192763107267474232.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-03-26 at 19:12 -0400, David Miller wrote:
> From: Greg KH <gregkh@linuxfoundation.org>
> Date: Mon, 26 Mar 2012 16:10:17 -0700
> 
> > David, please do NOT apply this as-is.
> 
> BTW, ethtool had controls exactly for stuff like this.

Not sure what you're thinking of...?  We have pause frame control but I
don't think that's applicable.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
