From: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: iwlwifi warnings
Date: Tue, 20 Feb 2007 23:32:47 -0800
Message-ID: <20070220233247.5d5f76b7.randy.dunlap@oracle.com>
References: <45CCE3CA.4050904@linux.intel.com>
	<20070213181313.GA5350@ucw.cz>
	<45D254C6.7050401@linux.intel.com>
	<20070219224432.GD21199@elf.ucw.cz>
	<45DBE559.8080903@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>,
	James Ketrenos <jketreno-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ipw3945-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Stephen Hemminger <shemminger-3NddpPZAyC0@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <45DBE559.8080903-3NddpPZAyC0@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 20 Feb 2007 22:23:21 -0800 Stephen Hemminger wrote:

> BUilding with sparse shows lots of warnings.
> 
> 
> $ make C=1
> Checking kernel compatibility in:
>     /lib/modules/2.6.20.1/source
>  * Kernel supports required features for 'tip' version.
> Building compatibility version in 'compatible/' directory:
> Copying compatible/ from origin/...done
> make -C /lib/modules/2.6.20.1/build M=/home/shemminger/src/iwlwifi-0.0.8 
> modules

[snip]

Good point(s).  Please try to use Documentation/SubmitChecklist,
as indicated in Andrew's -mm announcements (and copied in my sig below).

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
