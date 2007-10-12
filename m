From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 0/6] sky2 patches for net-2.6
Date: Thu, 11 Oct 2007 18:19:51 -0700
Message-ID: <20071012011951.575936605@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:38047 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753532AbXJLBWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 21:22:24 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Includes:
   * fix for new NAPI status loop
   * use internal net_stats
   * fixes for fiber PHY power

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

