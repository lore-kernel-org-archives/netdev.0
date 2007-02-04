From: James Courtier-Dutton <James@superbug.co.uk>
Subject: Wireless network card capabilities
Date: Sun, 04 Feb 2007 10:42:26 +0000
Message-ID: <45C5B892.3000507@superbug.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from anchor-fallback-93.mail.demon.net ([194.217.242.93]:55745 "EHLO
	anchor-fallback-93.mail.demon.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751652AbXBDL5O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Feb 2007 06:57:14 -0500
Received: from anchor-post-32.mail.demon.net ([194.217.242.90]:3099 "EHLO
	anchor-post-32.mail.demon.net") by anchor-fallback-93.mail.demon.net
	with ESMTP id S5829170AbXBDKo7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Feb 2007 10:44:59 +0000
Received: from superbug.demon.co.uk ([80.176.146.252] helo=[192.168.0.10])
	by anchor-post-32.mail.demon.net with esmtp (Exim 4.42)
	id 1HDepH-0008ig-7Z
	for netdev@vger.kernel.org; Sun, 04 Feb 2007 10:42:27 +0000
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Can Wireless network cards receive and transmit on two channels at once?
I am thinking of implementing a way for a wireless VoIP phone on Linux 
being able to hand off from one AP to another without dropping the call.
For this to work, the wireless card must be able to chat on two channels 
during the handover, so as to not loose any voice packets.

James
