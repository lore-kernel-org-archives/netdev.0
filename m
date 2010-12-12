From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH 0/3 net-2.6] bnx2x: Backporting BE fixes from net-next
Date: Sun, 12 Dec 2010 16:11:35 +0200
Message-ID: <1292163095.20811.159.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev list" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Ben Hutchings" <benh@debian.org>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2936 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752076Ab0LLOMG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Dec 2010 09:12:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Backporting the fix for a broken 57712 LSO code as for Ben's
suggestions. Also fixing the same compilation warning that has been
fixed in the net-next.

thanks,
vlad


