From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 0/2 net-next] iproute2: VXLAN Group Policy extension
Date: Thu, 15 Jan 2015 14:54:24 +0100
Message-ID: <cover.1421329802.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:57897 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752683AbbAONyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 08:54:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen,

Against net-next branch. I assume you only want to apply patch 1/2 after
the next header sync. I've included 2/2 if anyone wants to use it now and
needs the header bits

Thomas Graf (2):
  vxlan: Group policy extension
  vxlan: synchronize <linux/if_link.h> header

 include/linux/if_link.h |  3 +++
 ip/iplink_vxlan.c       | 11 +++++++++++
 man/man8/ip-link.8.in   | 45 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 59 insertions(+)

-- 
1.9.3
