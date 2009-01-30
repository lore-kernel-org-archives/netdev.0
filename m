From: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>
Subject: ixgbe in kernel driver question
Date: Fri, 30 Jan 2009 17:11:01 +0100
Message-ID: <49832695.7020802@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:52117 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751525AbZA3QLF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2009 11:11:05 -0500
Received: from unknown (HELO [192.168.1.10]) (itcare_pstaszewski@[83.4.198.230])
          (envelope-sender <pstaszewski@itcare.pl>)
          by smtp.iq.pl with AES256-SHA encrypted SMTP
          for <netdev@vger.kernel.org>; 30 Jan 2009 16:11:02 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have question about ixgbe in kernel driver compared to ixgbe driver 
that is on sourceforge
http://sourceforge.net/project/showfiles.php?group_id=42302&package_id=247088

What is difference between this drivers ?
and does driver in kernel 2.6.28.2

ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 1.3.30-k2
ixgbe: Copyright (c) 1999-2007 Intel Corporation.
ixgbe 0000:01:00.0: setting latency timer to 64

is this driver closest version to :
http://sourceforge.net/project/shownotes.php?release_id=611160&group_id=42302

on e1000.sourcerofge ??


Or this driver have different versions releases ? with different changes 
that are made in kernel tree network drivers

because i have problems with in kernel ixgbe drivers that i can compare 
to some fixes that are made in:
1.3.31.5 driver on e1000 site
http://sourceforge.net/project/shownotes.php?release_id=611160&group_id=42302

i think about this fix:

cpu utilization fix for MSI and legacy interrupts in kernels with CONFIG_NETDEVICES_MULTIQUEUE enabled but default (non multiqueue) aware qdisc loaded





