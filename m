From: "xerces8" <xerces8@butn.net>
Subject: "Listenless" TCP over NAT?
Date: Fri, 05 Sep 2008 13:45:13 +0200
Message-ID: <WorldClient-F200809051345.AA45130148@butn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: "Linux Netdev" <netdev@vger.kernel.org>,
	"Linux Networking" <linux-net@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ikar.perftech.si ([195.246.0.20]:4024 "EHLO ikar.perftech.si"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752397AbYIEMEm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2008 08:04:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

Recently someone mentioned on this (or maybe other...) list a seldom used
technique of establishing a TCP connection without one host listening on a port,
but but acting as "clients" and connecting to the peers port.

My question: Can this be used to establish a TCP connection between two hosts that
are both behind a (P)NAT router ?

(the idea being: NAT router lets outgoing connections thru, and in this case both
NAT router would  see an "outgoing" connection)

If yes, this would simplify the life of many users :-)

Regards,
David


