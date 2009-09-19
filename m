From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: b43 is broken in latest net-2.6 and linux-2.6
Date: Sat, 19 Sep 2009 13:23:11 +0200
Message-ID: <4AB4BF1F.7070501@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:20251 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752226AbZISLXK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Sep 2009 07:23:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Michael,

my b43 wireless card (Dell 830) is not working with the latest net-2.6 (and
also linux-2.6 2.6.31-05767-gdf58bee).

net-2.6 2.6.31-03263-gc29854e is working
net-2.6 2.6.31-03301-ga97e178 is broken

I removed the patch with the work_queue stuff which did not help - so it's
probably the other patch you added to b43 recently.

Don't know ... the wlan0 link does not become ready anymore.

If you need some more information - please let me know.

Best regards,
Oliver
