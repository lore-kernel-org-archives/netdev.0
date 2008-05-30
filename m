From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 0/7] TLAN driver cleanups
Date: Fri, 30 May 2008 09:49:51 -0700
Message-ID: <20080530164951.033143725@vyatta.com>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>, Samuel Chessman <chessman@tux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:34071 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751927AbYE3QxN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 12:53:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Give this driver some tough love, cleanup issues that indicate it
never gets used much on modern 2.6 systems.

-- 

