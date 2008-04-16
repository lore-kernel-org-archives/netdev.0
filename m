From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 00/13] Network driver changes for 2.6.26
Date: Wed, 16 Apr 2008 16:37:27 -0700
Message-ID: <20080416233727.732025083@vyatta.com>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:43757 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750710AbYDPXtX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 19:49:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pile of random small changes mostly janitorial cleanups related
to netdev_alloc_skb.  Please don't just apply these without ack
since in most cases they are compile tested only.

-- 

