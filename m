From: "Leonid Grossman" <Leonid.Grossman@neterion.com>
Subject: RE: one vs. two drivers for an iWARP-capable Ethernet NIC
Date: Thu, 28 Dec 2006 16:31:13 -0500
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD77010FB436@nekter>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <openib-general@openib.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:37533 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755002AbWL1VbQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Dec 2006 16:31:16 -0500
Received: from owa.neterion.com (unknown [72.1.205.142])
	by barracuda.s2io.com (Spam Firewall) with ESMTP id B81F820049B5
	for <netdev@vger.kernel.org>; Thu, 28 Dec 2006 16:31:15 -0500 (EST)
Content-class: urn:content-classes:message
To: "Jeff Garzik" <jgarzik@pobox.com>, <rdreier@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Re-sending as a plain text to reach netdev.
Sorry for the extra traffic, please ignore the earlier html version of
this e-mail...
------------------------------------------------------------
	
Jeff/Roland/all,
What is the preferred submission driver model for an iWARP-capable
Ethernet NIC - two separate drivers (Ethernet and OpenFabrics) that
interact with each other, or a single driver that supports both
OpenFabrics and Ethernet interfaces?

For our hardware we can go either way, although in case of separate
drivers the interface between the two would get somewhat artificial...
	 
	Thanks, Leonid


