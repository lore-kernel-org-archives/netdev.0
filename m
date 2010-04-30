From: Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>
Subject: Re: sierra_net default m
Date: Fri, 30 Apr 2010 11:45:50 -0700
Message-ID: <1272653150.9050.20.camel@Linuxdev3>
References: <20100430172838.GJ27497@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Rory Filer <rfiler-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	linux-usb <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100430172838.GJ27497-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2010-04-30 at 10:28 -0700, Jens Axboe wrote:
> Hi,
> 
> Can we please not add new drivers that default to y/m? Any new driver
> should default to 'n'.
> 
Hi,
OK. Makes sense, so that the kernel does not build the driver if the
configuration option is not explicitly set.


David, would you like me to issue a patch for that for sierra_net
driver?
Is this the general rule one should follow when adding a new driver?

Thanks,
Elina

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
