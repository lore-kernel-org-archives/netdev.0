From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next v2 0/2] bnx2x: net-next FW upgrade
Date: Mon, 1 Oct 2012 15:46:18 +0200
Message-ID: <1349099180-5606-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3171 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751896Ab2JANqR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2012 09:46:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This is a respin of previous series contains 2 patches -
the first allows the bnx2x and cnic driver to
utilize the recently submitted bnx2x FW 7.8.2, while the second advances
the bnx2x version to 1.78.00-0.

Changes since V1:
	Integrated changes to CNIC driver for FW 7.8.2.

Thanks,
Dmitry
