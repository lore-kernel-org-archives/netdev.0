From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 00/16] xfrm netlink interface cleanups
Date: Wed, 22 Aug 2007 16:55:38 +0200
Message-ID: <20070822145538.861270927@lsx.localdomain>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56948 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759394AbXHVP3Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 11:29:16 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset converts the xfrm netlink bits over to the type
safe netlink interface and does some cleanups.

 xfrm_user.c | 1041 ++++++++++++++++++++++++------------------------------------
 1 file changed, 433 insertions(+), 608 deletions(-)

