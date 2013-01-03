From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH 0/1] qlcnic: fix error reported by test robot
Date: Thu,  3 Jan 2013 04:10:14 -0500
Message-ID: <1357204215-17607-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:44249 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751134Ab3ACJaE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jan 2013 04:30:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

0001-qlcnic-fix-build-error.patch

The above patch fixes the error reported by kbuild test robot.
static declaration of 'qlcnic_restore_indev_addr' follows
non-static declaration.

Please apply to net-next.

Thanks,
Sony
