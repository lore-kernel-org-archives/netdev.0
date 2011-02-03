From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: sending IP pkgs form user space on a specific interface?
Date: Thu, 3 Feb 2011 22:55:37 +0100
Message-ID: <OFAEE2A3EA.1C3F2C8A-ONC125782C.0077F327-C125782C.007872C6@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:38374 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751684Ab1BCWCn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Feb 2011 17:02:43 -0500
Received: from sesr04.transmode.se (sesr04.transmode.se [192.168.201.15])
	by gw1.transmode.se (Postfix) with ESMTP id 592B3650001
	for <netdev@vger.kernel.org>; Thu,  3 Feb 2011 22:55:37 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Is there a way to specify what I/F a IP pkg should be sent
out on?

I have multiple ppp I/Fs with the same local and remote address
and I need to specify what interface to send OSPF protocol
messages to.

 Jocke

