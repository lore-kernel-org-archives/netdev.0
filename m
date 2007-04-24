From: Stephen Hemminger <shemminger@linux-founsation.org>
Subject: [PATCH 0/4]  TCP related patches for net-2.6.22
Date: Mon, 23 Apr 2007 20:31:17 -0700
Message-ID: <20070424033117.873984872@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:36461 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161562AbXDXDgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2007 23:36:15 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A bunch of TCP congestion control updates for 2.6.22.

The first one might be a bug fix worth backporting.
It addresses a problem that causes vegas not to work right
when using the setsockopt() setup.

-- 

