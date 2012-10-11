From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] kaweth: print correct debug ptr
Date: Thu, 11 Oct 2012 15:13:35 -0400 (EDT)
Message-ID: <20121011.151335.140562222217926591.davem@davemloft.net>
References: <20121011162158.2432.70215.stgit@bob.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20121011162158.2432.70215.stgit-Z/y2cZnRghHXmaaqVzeoHQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Date: Thu, 11 Oct 2012 17:22:03 +0100

> From: Alan Cox <alan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
> 
> We nowdays copy the buffer and free fw->data, so make the debug printk use
> the right thing.
> 
> Signed-off-by: Alan Cox <alan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>

Applied and queued up for -stable.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
