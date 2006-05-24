From: "Gary Zambrano" <zambrano@broadcom.com>
Subject: [PATCH 0/4] b44: add wol to b44
Date: Wed, 24 May 2006 07:40:35 -0700
Message-ID: <1148481635.2976.49.camel@dhcp-10-7-81-7.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:50706 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S932771AbWEXVm5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 May 2006 17:42:57 -0400
To: "Jeff Garzik" <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Adding wol to b44 is included in these patches:
1/4 - add wol and setup for later 4401 
2/4 - wol setup for older 4401
3/4 - add parameter to init_hw() for wol
4/4 - update version

