From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 0/4] skge: update
Date: Fri, 02 Feb 2007 08:22:50 -0800
Message-ID: <20070202162250.980620000@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:56742 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1945970AbXBBQZc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Feb 2007 11:25:32 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Several enhancements: WOL now works, use dev_printk macros
and allow handling broken hardware better.

-- 

