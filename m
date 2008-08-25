From: Scott Feldman <scofeldm@cisco.com>
Subject: [RFC][PATCH 0/3] enic: initial submission of driver for Cisco 10G
 Ethernet
Date: Mon, 25 Aug 2008 11:26:17 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0808251119440.3972@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuova-ex1.nuovasystems.com ([67.91.200.196]:15436 "EHLO
	nuova-ex1.nuovasystems.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753934AbYHYStY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2008 14:49:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patches add a driver for a 10G Ethernet NIC.  The
device/driver supports the standard stateless offloading features.

Cisco is working on developing a new product offering that will
leverage open-source code and will use specialized network adapter for
connectivity to existing LAN and SAN infrastructures.  The submitted
driver is required to guarantee the proper level of interoperability
and support.

This driver was written by myself.

The patches are against 2.6.26.3.

I would appreciate any review comments.

          Thanks,
          Scott
