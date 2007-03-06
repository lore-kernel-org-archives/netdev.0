From: "xerces8" <xerces8@butn.net>
Subject: GMRP support ?
Date: Tue, 06 Mar 2007 14:54:33 +0100
Message-ID: <WorldClient-F200703061454.AA54330209@butn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ikar.perftech.si ([195.246.0.20]:41314 "EHLO ikar.perftech.si"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965026AbXCFOOP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 09:14:15 -0500
Received: from dedal.perftech.si (unknown [10.12.0.44])
	by ikar.perftech.si (Spam Firewall) with ESMTP id AB209A2D64
	for <netdev@vger.kernel.org>; Tue,  6 Mar 2007 14:54:37 +0100 (CET)
Received: from WorldClient by butn.net
	(MDaemon PRO v9.5.4)
	with ESMTP id 40-md50000231065.msg
	for <netdev@vger.kernel.org>; Tue, 06 Mar 2007 14:54:35 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(reposted from linux-net)

Hi!

Is there any work on IEEE 802.1D GARP/GMRP support in linux?

(GMRP tells switches about multicast group membership, read :
no more broadcasting of multicast traffic, but sending only
to interested parties.)

I have no idea of support level in switches, I guess it is
a chicken-egg problem.

Regards,
David

PS: Or is that Cisco "standard" (can't recall it's name right now)
supported ? multicast is mandatory in IPv6 so it can be ignored any more ;)


