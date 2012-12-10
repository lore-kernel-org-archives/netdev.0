From: Peter Hurley <peter@hurleysoftware.com>
Subject: netconsole fun
Date: Mon, 10 Dec 2012 13:00:05 -0500
Message-ID: <1355162405.4658.6.camel@thor>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout39.mail01.mtsvc.net ([216.70.64.83]:42238 "EHLO
	n12.mail01.mtsvc.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751093Ab2LJSAQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2012 13:00:16 -0500
Received: from n18.c08.mtsvc.net ([205.186.176.18]:50205)
	by n12.mail01.mtsvc.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.63)
	(envelope-from <peter@hurleysoftware.com>)
	id 1Ti7eH-0004Ie-9X
	for netdev@vger.kernel.org; Mon, 10 Dec 2012 13:00:15 -0500
Received: from 68-189-242-29.dhcp.oxfr.ma.charter.com ([68.189.242.29]:51968 helo=[192.168.1.139])
	by n18.c08.mtsvc.net with esmtpsa (TLS1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	(envelope-from <peter@hurleysoftware.com>)
	id 1Ti7eB-0003zf-5Z
	for netdev@vger.kernel.org; Mon, 10 Dec 2012 10:00:12 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is there a recommended method of running netconsole on a machine that
has a slaved device?

I ask because it seems pretty difficult to get netconsole running even
on a machine that has multiple physical interfaces, only one of which is
slaved.

I scoured the documentation but didn't find anything relevant (does
documentation/networking/netconsole.txt need a patch?). AFAICT, the last
discussion ended here back in June '11
http://lkml.indiana.edu/hypermail/linux/kernel/1106.1/03185.html 

Any help or pointers provided would be much appreciated.

Regards,
Peter Hurley
