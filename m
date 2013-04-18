From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH v2 net-next 0/4] bnx2x: refactor nvram related code and
 update version
Date: Thu, 18 Apr 2013 13:27:06 +0300
Message-ID: <1366280830-26034-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2122 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964916Ab3DRK1Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 06:27:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Please cosider appliyng the series to net-next.

Changes for v2:
	* 1/4: remove boolean parameter and introduce bnx2x_nvram_read32
	*      pointed out by Francois Romieu <romieu@fr.zoreil.com>
	* 2/4: adopt to changes in [1/4] 

Thanks
Dmitry
