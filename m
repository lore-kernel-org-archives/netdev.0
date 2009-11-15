From: dag@bakke.com
Subject: Phonet userspace bits?
Date: Sun, 15 Nov 2009 16:15:25 +0000 (GMT)
Message-ID: <1272976626.71600.1258301725789.JavaMail.mail@webmail06>
References: <!256485B18-474275-V2@support.norwegian.no>
Reply-To: dag@bakke.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0222.hostedemail.com ([216.40.44.222]:56219 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753232AbZKOQPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Nov 2009 11:15:22 -0500
Received: from filter.hostedemail.com (ff-bigip1 [10.5.19.254])
	by smtprelay03.hostedemail.com (Postfix) with SMTP id DAD0B974E56
	for <netdev@vger.kernel.org>; Sun, 15 Nov 2009 16:15:25 +0000 (UTC)
Received: from webmail06 (imap-ext [216.40.42.5])
	(Authenticated sender: dag@bakke.com)
	by omf01.hostedemail.com (Postfix) with ESMTP
	for <netdev@vger.kernel.org>; Sun, 15 Nov 2009 16:15:25 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

How do an end-user make use of a phonet network interface?

Nov 15 16:31:54 toshr500 usb 1-1: New USB device found, idVendor=0421, idProduct=046e
Nov 15 16:31:54 toshr500 usb 1-1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
Nov 15 16:31:54 toshr500 usb 1-1: Product: Nokia 6110 Navigator
Nov 15 16:31:54 toshr500 usb 1-1: Manufacturer: Nokia
Nov 15 16:31:54 toshr500 usb 1-1: configuration #1 chosen from 1 choice
Nov 15 16:31:54 toshr500 cdc_acm 1-1:1.8: ttyACM0: USB ACM device

So I can use /dev/ttyACM0 with pppd and get a 3G connection. so far, so good.

But what is the usbpn0 network interface, and could I use that instead of fiddling with chatscripts and pppd, to get a 3G connection?
Is this feature complete? 

Google came up short on this topic, and the kernel documentation did not enlighten me.
The best I find is http://kerneltrap.org/mailarchive/linux-usb/2009/7/21/6243913 .
Does this still describe the current state of affairs?


Thanks,

Dag B 
