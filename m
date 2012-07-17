From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 0/4 v3 net-next] tg3: Add hwmon support
Date: Mon, 16 Jul 2012 19:23:58 -0700
Message-ID: <1342491842-29818-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3889 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754317Ab2GQCMa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2012 22:12:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


David, I've removed the binary sysfs attribute and now use
hwmon only.  Please consider this patchset for net-next.
