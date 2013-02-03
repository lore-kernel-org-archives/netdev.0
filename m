From: =?UTF-8?B?RMOibmllbA==?= Fraga <fragabr@gmail.com>
Subject: Annoying e1000e link up and down issue
Date: Sun, 3 Feb 2013 02:02:23 -0200
Message-ID: <kekr0s$kah$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:58520 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750705Ab3BCFCf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Feb 2013 00:02:35 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1U1rjA-0006OF-GY
	for netdev@vger.kernel.org; Sun, 03 Feb 2013 06:02:52 +0100
Received: from 200-148-10-98.dsl.telesp.net.br ([200.148.10.98])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 03 Feb 2013 06:02:52 +0100
Received: from fragabr by 200-148-10-98.dsl.telesp.net.br with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 03 Feb 2013 06:02:52 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Can someone take a look at this bug?

https://bugzilla.kernel.org/show_bug.cgi?id=53291

	There're many e1000e users dealing with this problem, so it
seems to be a long time bug with this driver.

	Thanks.

-- 
Linux 3.7.0: Terrified Chipmunk
http://www.youtube.com/DanielFragaBR
http://www.libertarios.org.br
