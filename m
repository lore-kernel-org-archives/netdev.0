From: Alex Juncu <ajuncu@ixiacom.com>
Subject: [PATCH 0/1] Adding examples in ip man page on basic use of the ip
 command.
Date: Thu, 24 Nov 2011 14:00:32 +0200
Message-ID: <4ECE31E0.3050403@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <shemminger@vyatta.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 207.47.100.214.static.nextweb.net ([207.47.100.214]:55944 "EHLO
	ixqw-mail-out.ixiacom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752685Ab1KXMFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 07:05:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

I believe that some people are scared by the size of the ip man page 
(1600 lines vs 180 of ifconfig) and don't use iproute2 because they 
can't figure out how to use it. A lot of man pages for other tools 
provide examples on how to use the tool with its basic features.

So I am suggesting adding a couple of examples to the man page of 
iproute2 (ip command) in order to be more friendly for beginners.

This is the first time I submit a patch (even if it is a very small one) 
and I hope I got the procedure right.

--
Alexandru Juncu
