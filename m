From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: future developments of usbnet
Date: Tue, 10 May 2011 11:42:15 +0200
Message-ID: <20110510094214.GA2970@riccoc20.at.omicron.at>
References: <201105062045.37336.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <201105062045.37336.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, May 06, 2011 at 08:45:37PM +0200, Oliver Neukum wrote:
> Hi,
> 
> I'd like to get a feeling what people are working out there regarding usbnet.
> So please, if you do something, or think something ought to be done, please
> speak up now.
> 
> IMHO usbnet needs better support for
> 
> - batching protocols
> - double buffering on the rx path

I would like see phylib and (if possible) NAPI, although for different
reasons than the problems mentioned in this thread. I am willing and
able to do the work, but I obviously don't have all of the usbnet
hardware available for testing.

Thanks,

Richard
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
