From: Inaky Perez-Gonzalez <inaky-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: [ANN] WiMAX stack and drivers for Intel WiMAX Link 5050
Date: Tue, 1 Apr 2008 11:07:37 -0700
Message-ID: <200804011107.38563.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: wimax-BPSAo7wm5JOHVYUYWc+uSQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Intel would like to announce the initial release of a Linux WiMAX 
common stack and drivers for its WiMAX devices (eg: Intel(r) 
WiMAX/WiFi Link 5050, with estimated availability around third 
quarter of 2008).

The project follows a standard layered approach: a generic WiMAX 
kernel stack provides a common interface to control WiMAX devices. 
A user space daemon and libraries provide a high level API for 
control (network scanning, connection, disconnection, roaming 
management, etc) and access to the drivers. 

Currently much of this higher level code is tailored to Intel's 
device, but we wanted to get it out as soon as possible.

You can find the code and additional information at
http://linuxwimax.org.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
