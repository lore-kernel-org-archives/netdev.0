From: "Yaniv Rosner" <yaniv.rosner@broadcom.com>
Subject: [PATCH net-next 00/10] bnx2x: Dual-media enhancement
Date: Wed, 8 Sep 2010 00:40:45 +0300
Message-ID: <1283895645.5452.60.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3059 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932346Ab0IGSWi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Sep 2010 14:22:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,
The following patch series describe gradually code changes to support
dual-media boards. Among other, this change required to split common PHY
functions into PHY specific functions, so we took advantage of this
opportunity and moved to a method which is very similar to the phy lib,
i.e. PHY oriented. We hope that this way will enable us to integrate
with the phy lib easily later on.

Please consider applying it to net-next.

Thanks,
Yaniv


