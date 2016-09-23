From: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] Net Driver: Add Cypress GX3 VID=04b4 PID=3610.
Date: Fri, 23 Sep 2016 21:00:14 +0200
Message-ID: <20160923190014.GA31204@kroah.com>
References: <a6cbbf76a41946efa9f87dc15d4bba53@Mail07.usask.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: chris.roth-/KKvz3x1pcI@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <a6cbbf76a41946efa9f87dc15d4bba53-7W3tOxt+DW0TrS4zaltX1A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 23, 2016 at 12:24:50PM -0600, chris.roth-/KKvz3x1pcI@public.gmane.org wrote:
> From: Chris Roth <chris.roth-/KKvz3x1pcI@public.gmane.org>
> 
> Add support for Cypress GX3 SuperSpeed to Gigabit Ethernet
> Bridge Controller (Vendor=04b4 ProdID=3610).
> 
> Patch verified on x64 linux kernel 4.7.4 system with the
> Kensington SD4600P USB-C Universal Dock with Power, which uses the
> Cypress GX3 SuperSpeed to Gigabit Ethernet Bridge Controller.
> 
> A similar patch was signed-off and tested-by Allan Chou
> <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org> on 2015-12-01.

Then you should put a "From: " line at the top of this patch that looks
like:
From: Allan Chou <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
at the top of the patch and then a blank line, and put the signed-off-by
back in the patch as well, with yours below it.  The file
Documentation/SubmittingPatches should show you how to do this.

Can you try again?

thanks,

greg k-h
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
