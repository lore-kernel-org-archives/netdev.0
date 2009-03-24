From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 0/9] s390: lcs / ctcm / claw / netiucv patches for 2.6.29
Date: Tue, 24 Mar 2009 13:29:04 +0100
Message-ID: <20090324122904.744942000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:36551 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756517AbZCXMni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 08:43:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

here are a couple of drivers/s390/net-patches for 2.6.29 :

1/9: lcs:     exploit <linux/kthread.h>          - Klaus-Dieter Wacker
2/9: lcs:     hard_start_xmit return codes       - Klaus-Dieter Wacker
3/9: netiucv: hard_start_xmit return codes       - Ursula Braun
4/9: claw:    hard_start_xmit return codes       - Ursula Braun
5/9: ctcm:    hard_start_xmit return codes       - Ursula Braun
6/9: ctcm:    avoid wraparound in length of incoming data - Roel Kluin
7/9: ctcm:    minor findings from code analysis tool      - Joel Fowler
8/9: claw:    convert printk messages to kmsg api    - Andy Richter
9/9: claw:    minor findings from code analysis tool - Andy Richter

Thanks and regards,
Ursula
