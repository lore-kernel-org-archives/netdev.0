From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] remove comx drivers from tree
Date: Sun, 16 May 2004 17:54:35 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <40A7E31B.5020705@pobox.com>
References: <20040507111725.GA11575@lst.de> <40A50292.3070601@pobox.com> <m3sme1cqqg.fsf@defiant.pm.waw.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@lst.de>, netdev@oss.sgi.com,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>, Pete Popov <ppopov@mvista.com>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S264829AbUEPVyw@vger.kernel.org>
To: Krzysztof Halasa <khc@pm.waw.pl>
In-Reply-To: <m3sme1cqqg.fsf@defiant.pm.waw.pl>
List-Id: netdev.vger.kernel.org

Krzysztof Halasa wrote:
> While obviously I don't object (we should list removed things along
> with kernel version somewhere, though)... I could possibly port
> the drivers to my generic HDLC code, if someone sends me the hardware
> in question. Sure, I will never send it back, and it has to have V.35
> or V.24 interface, so I can connect it to something.

Then, *bang*, it's gone :)

We can resurrect if someone appears with hardware, and cares enough to 
bring the driver back to life...  Older kernels are archived on the 
Internet forever, after all :)

	Jeff
