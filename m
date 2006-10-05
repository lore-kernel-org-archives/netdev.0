From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 0/4] skge: fiber related fixes
Date: Thu, 05 Oct 2006 15:49:49 -0700
Message-ID: <20061005224949.456192755@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:63439 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751524AbWJEXzA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2006 19:55:00 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches address the problems that were causing a fiber
connected SysKonnect board to revert to have performance problems.
They fix flow control, duplex, and irq masking issues.

--
Stephen Hemminger <shemminger@osdl.org>

