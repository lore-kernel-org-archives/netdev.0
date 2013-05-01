From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 0/2] bnx2x: Bug patch series
Date: Wed, 1 May 2013 17:27:56 +0300
Message-ID: <1367418478-7416-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4734 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756101Ab3EAP2Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 May 2013 11:28:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This fixes 2 small bugs - one which may cause an unnecessary link flap,
and the other is a small memory leak when unloading while cnic is not 
loaded.

Please consider applying these patches to `net'.

Thanks,
Yuval Mintz
