From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: PHY down?
Date: Tue, 2 Aug 2011 11:24:29 +0200
Message-ID: <OF6D5A2ABF.61D9AA63-ONC12578E0.00335EE4-C12578E0.0033AE22@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:44222 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752892Ab1HBJak (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2011 05:30:40 -0400
Received: from mail1.transmode.se (mail1.transmode.se [192.168.201.18])
	by gw1.transmode.se (Postfix) with ESMTP id 10509258194
	for <netdev@vger.kernel.org>; Tue,  2 Aug 2011 11:24:30 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I must be missing something obvious but I cannot find how
to bring eth0's PHY down (link down) from user space.
Tried various settings with ethtool and ifconfig eth0 down but it didn't help.

 Jocke

