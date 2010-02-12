From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: convert dev(dbg|err|warn|info) macros to
 usbnet_(dbg|err|warn|info)
Date: Fri, 12 Feb 2010 12:38:37 -0800 (PST)
Message-ID: <20100212.123837.56526847.davem@davemloft.net>
References: <201002092153.22322.david-b@pacbell.net>
	<1265782578.20626.17.camel@Joe-Laptop.home>
	<201002092256.30175.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, gregkh@suse.de, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	oliver@neukum.name, jacmet@sunsite.dk, steve.glendinning@smsc.com
To: david-b@pacbell.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201002092256.30175.david-b@pacbell.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Brownell <david-b@pacbell.net>
Date: Tue, 9 Feb 2010 22:56:29 -0800

> On Tuesday 09 February 2010, Joe Perches wrote:
> 
>> netdev_printk macros instead.
>> 
>> http://patchwork.ozlabs.org/patch/44955/
> 
> That'd make sense.  Had they existed way back when ...
> they could have been used instead of custom stuff.

Joe, this patch doesn't apply cleanly to net-next-2.6 so could
you respin whatever variant of this you want me to apply?

Thanks!
