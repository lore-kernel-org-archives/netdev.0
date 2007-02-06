From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 0/7] sky2 v1.12 patches
Date: Tue, 06 Feb 2007 10:45:38 -0800
Message-ID: <20070206184538.675048000@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:45581 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752269AbXBFSxG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Feb 2007 13:53:06 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

New driver version for 2.6.21 inclusion:
* WOL
* TSO support for 88E8055
* more PCI id's
* experimental support for Yukon Extreme

Patches are against current netdev-2.6#upstream

--
Stephen Hemminger <shemminger@linux-foundation.org>

