From: Stefan Rompf <stefan@loplof.de>
Subject: Re: [Announce] Intel PRO/Wireless 3945ABG Network Connection
Date: Sat, 25 Feb 2006 13:29:03 +0100
Message-ID: <200602251329.03933.stefan@loplof.de>
References: <43FF88E6.6020603@linux.intel.com> <200602250549.47547.gene.heskett@verizon.net> <20060225105340.GA23643@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: gene.heskett@verizononline.net,
	James Ketrenos <jketreno@linux.intel.com>,
	NetDev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932684AbWBYM2c@vger.kernel.org>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20060225105340.GA23643@infradead.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Samstag 25 Februar 2006 11:53 schrieb Christoph Hellwig:

>From a short glance over the driver code, the protocol between the _open 
source_ driver and the binary user space daemon seems to be quite defined and 
unobfuscated. Obviously, someone owning the device has to verify that the 
daemon doesn't tamper the hardware beyond the driver's back.

> We have support for other software radios. 

There is a difference. As kernel developers, we can put the responsibility to 
verify that a device can be operated legally on the user, as you said. A 
manufacturer, especially a huge one as Intel, is obligated to take this 
burden from their customers - obligated may be by law, may be by company 
policy.

> If intel doesn't do the right 
> thing support for their hardware will have to wait until someone has
> reverse-engineered their daemon [1].

If someone else reverse engineers and replaces the daemon, it may not be 
Intel's problem anymore - but that's all not the point.

Actually, Intel invested a lot of time to avoid shipping a binary only driver 
or a HAL like madwifi does. So however this settles, they deserve at least to 
be adressed in a less insulting tone than you do in your mails.

Thanks,

Stefan
