From: Markus Feldmann <feldmann_markus@gmx.de>
Subject: which stable usb wlan device
Date: Fri, 23 Apr 2010 00:30:09 +0200
Message-ID: <hqqilh$7rd$1@dough.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:42175 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753115Ab0DVWaU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Apr 2010 18:30:20 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1O54uX-0007BW-DN
	for netdev@vger.kernel.org; Fri, 23 Apr 2010 00:30:17 +0200
Received: from dslb-092-076-232-046.pools.arcor-ip.net ([92.76.232.46])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 23 Apr 2010 00:30:17 +0200
Received: from feldmann_markus by dslb-092-076-232-046.pools.arcor-ip.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 23 Apr 2010 00:30:17 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

i am searching for a wlan device. This should work as AP on Debian=20
Lenny(current kernel 2.6.32.11). So here are my requirements for this=20
device:

1.stable open source driver included in the kernel, not from an extern=20
source. I want to use this device as AP!
2.USB2 compatible
3.WPA2 compliant for more savety
4.adjustable transmission power to reduce the maximum range
5.A low power sonsumption as low as possible, a reference value is 1wat=
t
6.price should under 40=E2=82=AC=3D60$ as much as possible

I just found your new device side:
http://linuxwireless.org/en/users/Drivers/ath9k/devices

but are these devices who works well or not? If i buy such a device, is=
=20
only the Atheros Chip number important for me, or should i watch for th=
e=20
Subvendor ans Subsystem number too?

=46urther on i only found PCI devices. Is there a supported usb device=20
list too?

regards Markus

