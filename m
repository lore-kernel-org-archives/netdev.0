From: Asdo <asdo@shiftmail.org>
Subject: tcp_* settings change on the fly?
Date: Thu, 03 Dec 2009 23:21:02 +0100
Message-ID: <4B1839CE.2080000@shiftmail.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.isti.cnr.it ([194.119.192.4]:2010 "EHLO mx2.isti.cnr.it"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751376AbZLCWUk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2009 17:20:40 -0500
Received: from conversionlocal.isti.cnr.it by mx.isti.cnr.it (PMDF V6.4 #31773)
 id <01NGU5WCDVR490SCW5@mx.isti.cnr.it> for netdev@vger.kernel.org; Thu,
 03 Dec 2009 23:20:42 +0100
Received: from [10.0.0.2]
 (host-84-220-174-188.cust-adsl.tiscali.it [84.220.174.188])
 by mx.isti.cnr.it (PMDF V6.4 #31703)
 with ESMTPSA id <01NGU5WBOR6A95OCX8@mx.isti.cnr.it> for
 netdev@vger.kernel.org; Thu, 03 Dec 2009 23:20:42 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,
if I change some of the settings
/proc/sys/net/ipv4/tcp_*
does the change apply "on the fly" on existing established connections, 
or do I have to kill and reestablish the connections to have the change?
Thank you
