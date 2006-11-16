From: James Courtier-Dutton <James@superbug.co.uk>
Subject: Max number of TCP sessions
Date: Thu, 16 Nov 2006 20:23:37 +0000
Message-ID: <455CC8C9.2050509@superbug.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from anchor-post-33.mail.demon.net ([194.217.242.91]:30993 "EHLO
	anchor-post-33.mail.demon.net") by vger.kernel.org with ESMTP
	id S1424442AbWKPUXi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Nov 2006 15:23:38 -0500
Received: from superbug.demon.co.uk ([80.176.146.252] helo=[192.168.0.10])
	by anchor-post-33.mail.demon.net with esmtp (Exim 4.42)
	id 1Gknlp-0006aH-Ai
	for netdev@vger.kernel.org; Thu, 16 Nov 2006 20:23:37 +0000
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

For a host using a Pentium 4 CPU at 2.8Mhz, what is a sensible max value 
for number of TCP sessions this host could run under Linux?
Bandwidth per TCP session is likely to be about 10kbytes/second.

Kind Regards

James
