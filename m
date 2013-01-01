From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH V1 0/14] qlcnic: Qlogic 83xx CNA adapter driver patches
Date: Tue,  1 Jan 2013 08:20:16 -0500
Message-ID: <1357046430-31437-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:19410 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752263Ab3AANkR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jan 2013 08:40:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Patches 1-2 refactors the existing 82xx driver

0001-qlcnic-change-driver-hardware-interface-mechanism.patch
0002-qlcnic-macros-for-common-register-access.patch

Patches 3-14 add logical features of 83xx adpater

0003-qlcnic-83xx-memory-map-and-HW-access-routines.patch
0004-qlcnic-83xx-data-path-routines.patch
0005-qlcnic-83xx-base-driver.patch
0006-qlcnic-83xx-sysfs-routines.patch
0007-qlcnic-83xx-adpater-flash-interface-routines.patch
0008-qlcnic-83xx-CNA-inter-driver-communication-mechanism.patch
0009-qlcnic-flash-template-based-firmware-reset-recovery.patch
0010-qlcnic-enable-83xx-virtual-NIC-mode.patch
0011-qlcnic-83xx-register-dump-routines.patch
0012-qlcnic-83xx-ethtool-interface-routines.patch
0013-qlcnic-remove-unused-definitions-from-header-file.patch
0014-qlcnic-update-driver-version.patch

Please apply to net-next.

Thanks,
Sony
