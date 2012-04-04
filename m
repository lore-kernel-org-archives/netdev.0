From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net 00/10] bnx2x: Link fixes
Date: Wed, 4 Apr 2012 14:28:53 +0300
Message-ID: <1333538942-9904-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2740 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752447Ab2DDJ31 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2012 05:29:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,
The following patch series describe some link fixes.
These changes were held back a while until testing was completed to insure the
issues are really fixed. And though they are minor issues, we still prefer to
push those fixes to net and not just net-next as they improve the usability.
Please consider applying it to net.

Thanks,
Yaniv
