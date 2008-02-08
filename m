From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 0/5] s390: claw/lcs/netiucv network driver patches for 2.6.25
Date: Fri, 08 Feb 2008 13:09:00 +0100
Message-ID: <20080208120900.295604000@linux.vnet.ibm.com>
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:51973 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759068AbYBHMPO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 07:15:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-- 
Jeff,

The following patches are intended for 2.6.25.
They affect the s390 network drivers claw, lcs, and netiucv.

Patch summary:
  claw:    remove unused volatile variables
  netiucv: define module owner in device_driver structure
  netiucv: renaming of NOP action
  lcs:     improvement for debug area setup
  claw/lcs/netiucv: optimize a debugging macro

Regards, Ursula Braun
