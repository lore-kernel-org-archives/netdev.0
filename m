From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: Re: [ANN] WiMAX stack and drivers for Intel WiMAX Link 5050
Date: Tue, 1 Apr 2008 11:18:02 -0700
Message-ID: <20080401111802.65fe259f@extreme>
References: <200804011107.38563.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Inaky Perez-Gonzalez <inaky-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200804011107.38563.inaky-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 1 Apr 2008 11:07:37 -0700
Inaky Perez-Gonzalez <inaky-VuQAYsv1563Yd54FQh9/CA@public.gmane.org> wrote:

> 
> Intel would like to announce the initial release of a Linux WiMAX 
> common stack and drivers for its WiMAX devices (eg: Intel(r) 
> WiMAX/WiFi Link 5050, with estimated availability around third 
> quarter of 2008).
> 
> The project follows a standard layered approach: a generic WiMAX 
> kernel stack provides a common interface to control WiMAX devices. 
> A user space daemon and libraries provide a high level API for 
> control (network scanning, connection, disconnection, roaming 
> management, etc) and access to the drivers. 
> 
> Currently much of this higher level code is tailored to Intel's 
> device, but we wanted to get it out as soon as possible.
> 
> You can find the code and additional information at
> http://linuxwimax.org.
> 

Code review occurs on patch submittable not by pointing developers off
to an external project. Most likely there will be feedback that requires
changes to API and other choices so you want to do this soon.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
