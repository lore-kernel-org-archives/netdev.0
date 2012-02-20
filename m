From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH 0/5] bnx2x: fw update
Date: Mon, 20 Feb 2012 21:59:07 +0200
Message-ID: <1329767952-12605-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3378 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752134Ab2BTT7I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Feb 2012 14:59:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Dave,

The series updates bnx2x driver to use FW 7.2.16 which, was
recently applied in linux-firmware tree.

The firmware introduces GRO implementation in FW as long as
some fixes toward storage drivers.

Please consider applying the series to net-next.

Thanks
Dmitry
