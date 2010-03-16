From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH] smsc95xx: bugfix for net-2.6
Date: Tue, 16 Mar 2010 19:03:05 +0000
Message-ID: <1268766186-16014-1-git-send-email-steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 77-44-110-64.xdsl.murphx.net ([77.44.110.64]:53596 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933885Ab0CPTDI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 15:03:08 -0400
Received: from localhost.localdomain (unknown [10.0.20.109])
	by drevil2.shawell.net (Postfix) with ESMTP id E112F67B92
	for <netdev@vger.kernel.org>; Tue, 16 Mar 2010 19:03:06 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please consider this single bugfix for net-2.6.  I'll re-send the
other enhancement patches for net-next-2.6 when it opens.

Steve Glendinning (1):
  smsc95xx: wait for PHY to complete reset during init

 drivers/net/usb/smsc95xx.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

