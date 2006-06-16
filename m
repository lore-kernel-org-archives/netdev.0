From: "Gary Zambrano" <zambrano@broadcom.com>
Subject: [PATCH 0/6] b44: fixes for speed settings, addition of wol.
Date: Fri, 16 Jun 2006 12:18:54 -0700
Message-ID: <1150485534.8716.48.camel@dhcp-10-7-81-7.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:23570 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1750784AbWFPTTY
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jun 2006 15:19:24 -0400
To: "Jeff Garzik" <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series of patches is to update the b44 driver with the following changes:

1-fix the manual speed settings 
2-add wol functionality 
3-add a parameter to init_hw function to support wol
4-add wol for older nic
5-bump driver version to 1.01
6-modify the Kconfig b44 entry 

