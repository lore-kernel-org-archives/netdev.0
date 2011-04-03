From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next-2.6 0/2] be2net: Patches for fixing suspend/resume
Date: Sun, 3 Apr 2011 17:23:52 +0530
Message-ID: <756be716-7252-48f7-9a48-cf958c83a56f@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:1957 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752037Ab1DCLyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2011 07:54:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,
	Following are patches to fix suspend/resume operation.
Please apply.
Thanks,
Padmanabh

Padmanabh Ratnakar (2):
  be2net: Rename some struct members for clarity
  be2net: Fix suspend/resume operation

 drivers/net/benet/be.h      |    4 ++--
 drivers/net/benet/be_main.c |   11 ++++++-----
 2 files changed, 8 insertions(+), 7 deletions(-)

