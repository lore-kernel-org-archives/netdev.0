From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Expose netdevice dev_id through sysfs
Date: Sun, 20 Apr 2008 04:14:39 -0700 (PDT)
Message-ID: <20080420.041439.117533456.davem@davemloft.net>
References: <1208688644.9212.407.camel@pmac.infradead.org>
	<20080420.035515.12616544.davem@davemloft.net>
	<1208689966.9212.428.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kay.sievers@vrfy.org, md@linux.it, harald@redhat.com,
	linux-hotplug@vger.kernel.org, netdev@vger.kernel.org,
	schwidefsky@de.ibm.com
To: dwmw2@infradead.org
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <1208689966.9212.428.camel@pmac.infradead.org>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Woodhouse <dwmw2@infradead.org>
Date: Sun, 20 Apr 2008 12:12:46 +0100

> The reason I still submitted it, after realising that Marco's objections
> to letting udev rely on the 'KERNEL==' match were bogus, is because I
> think it does still help on S390 -- it lets us remove the special case
> hack there.
> 
> I don't think it's actually _broken_ on S390 at the moment; just a bit
> icky. That was sufficient motivation to still submit the patch :)

Fair enough.

Why don't you do the following?  Respin the patch with some
added verbiage in the changelog entry based upon what we've
discussed here and I'll apply the patch.

Thanks.
