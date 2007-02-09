From: James Ketrenos <jketreno-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: [ANNOUNCE] d80211 based driver for Intel PRO/Wireless 3945ABG
Date: Fri, 09 Feb 2007 13:12:42 -0800
Message-ID: <45CCE3CA.4050904@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ipw3945-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Please hold all questions until I am done with this email.  Thank you.

We are pleased to announce the availability of a new driver for the 
Intel PRO/Wireless 3945ABG Network Connection adapter.  This new driver 
uses the new d80211 subsystem previously only available as part of the 
wireless-dev tree.

You can find the new driver, and additional information about it, here:

   http://intellinuxwireless.org/iwlwifi.

Within the new driver package are sources which we plan to submit for 
kernel inclusion as well as scripts and patches which create a version 
of the driver which can be loaded into kernels based on 2.6.18 and newer 
(provided you have installed the d80211 subsystem as well)  The README 
document can walk you through pretty quickly.

Since a lot of our users are not able to move to the latest versions of 
the Linux kernel, we have put together a d80211 package allowing the 
installation of the d80211 subsystem into an existing kernel image 
without the need to migrate to wireless-dev, or upgrade to a newer 
kernel at all (assuming you are using 2.6.18 or newer).

You can find that package at:

   http://intellinuxwireless.org/d80211

Ok.  Now... any questions?

Thanks,
James / Intel Corporation
-
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
