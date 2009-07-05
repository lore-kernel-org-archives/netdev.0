From: "Jorge Bastos" <mysql.jorge@decimal.pt>
Subject: Crashes on ppp system
Date: Sun, 5 Jul 2009 17:00:15 +0100 (WEST)
Message-ID: <1201.87.196.129.60.1246809615.squirrel@webmail.decimal.pt>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrly04.isp.novis.pt ([195.23.133.224]:53133 "EHLO
	mailrly04.isp.novis.pt" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752059AbZGEQGu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2009 12:06:50 -0400
Received: from webmail.decimal.pt (localhost [127.0.0.1])
	by web.decimal.pt (Postfix) with ESMTP id C8CD82CB1F
	for <netdev@vger.kernel.org>; Sun,  5 Jul 2009 17:00:15 +0100 (WEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Howdy,
I have a machine used for GW at my job, and i have a PPTPD VPN setup on it
using poptop, and after updating to 2.6.30 i have crashes on the kernel
all the time.
Since i don't have the text, i made two pictures with it :P

http://neotrix.decimal.pt/dbmail/ppp_1.jpg
http://neotrix.decimal.pt/dbmail/ppp_2.jpg

As you can see on the pic, i'm using 2.6.31-rc1-git11 now, since 2.6.30
i've tryed several git versions that had some work on the kernel PPP
system, and the crash remains.

Is there anything else i can help on this?

Jorge,

