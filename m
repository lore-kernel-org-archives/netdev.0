From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net 0/3] be2net: Patch set
Date: Fri, 22 Nov 2013 12:50:55 -0600
Message-ID: <20131122185055.GA4131@emulex.com>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:23725 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754477Ab3KVSvA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Nov 2013 13:51:00 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please apply.

Ravikumar Nelavelli (1):
  be2net: Disabling and enabling interrupts in suspend and resume

Vasundhara Volam (2):
  be2net: set coalesce-wm in CQ_CREATE_V2 cmd
  be2net: Avoid programming permenant MAC by BE3-R VFs

 drivers/net/ethernet/emulex/benet/be.h      |  1 +
 drivers/net/ethernet/emulex/benet/be_cmds.c |  7 +++++++
 drivers/net/ethernet/emulex/benet/be_main.c | 12 ++++++------
 3 files changed, 14 insertions(+), 6 deletions(-)

-- 
1.8.1.2
