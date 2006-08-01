From: a1 <a1k@mail.ru>
Subject: e1000 speed/duplex error
Date: Tue, 1 Aug 2006 14:18:27 +0400
Message-ID: <1301563340.20060801141827@mail.ru>
Reply-To: a1 <a1k@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.mail.ru ([194.67.23.121]:49287 "EHLO mx1.mail.ru")
	by vger.kernel.org with ESMTP id S932556AbWHAKSE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 06:18:04 -0400
Received: from [217.171.5.250] (port=53152 helo=kot)
	by mx1.mail.ru with psmtp
	id 1G7rK6-000B7B-00
	for netdev@vger.kernel.org; Tue, 01 Aug 2006 14:18:02 +0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm trying to set my nic to force 100Mb/FD, but I'm constantly getting 100/HD on
other side of the link.

The command is:
ethtool -s eth0 speed 100 duplex full autoneg off

e1000 driver version 7.1.9 (latest) downloaded from sourceforge.

Are there any problems?

-- 
 alkot                          mailto:a1k@mail.ru

