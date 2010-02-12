From: Radu Potop <wooptoo@gmail.com>
Subject: rtl8180 driver in master/ad-hoc mode
Date: Fri, 12 Feb 2010 16:53:00 +0200
Message-ID: <4B756B4C.2090204@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:28051 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754666Ab0BLOxF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 09:53:05 -0500
Received: by fg-out-1718.google.com with SMTP id 16so266768fgg.1
        for <netdev@vger.kernel.org>; Fri, 12 Feb 2010 06:53:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

	I noticed that the rtl8180 (Realtek wireless PCI adapter) driver for Linux 
doesn't support master or ad-hoc mode. However the rtl-wifi driver from 
http://rtl-wifi.sourceforge.net does support these modes.
	After a bit of investigation, I found out that the driver from the kernel is 
not maintained by its original author anymore (no changes since 2007), while 
rtl-wifi development is active.

	My question is if rtl-wifi will make it into the kernel? rtl-wifi is actually a 
fork of the old driver, but with a lot of added functionality. I'm sure that a 
lot of folks would like to use their hardware to its full potential.

Thank you,
Radu Potop
