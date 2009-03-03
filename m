From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 0/8] Add/clean up firmware event handlers.
Date: Tue,  3 Mar 2009 14:10:29 -0800
Message-ID: <1236118237-14483-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:50781 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761739AbZCCWNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 17:13:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

These 8 patches add more support for handing inbound firmware events and
clean up some of the existing event handlers.

Regards,
Ron Mercer

0001-qlge-Add-firmware-support-for-insert-remove-SFP.patch
0002-qlge-Clean-up-link-down-processing.patch
0003-qlge-Clean-up-link-up-processing.patch
0004-qlge-Add-worker-handler-for-firmware-events.patch
0005-qlge-Clean-up-event-handler-for-firmware-init.patch
0006-qlge-Improve-handling-for-firmware-init-failure.patch
0007-qlge-Save-status-from-firmware-crash-system-err.patch
0008-qlge-Add-support-for-lost-firmware-events.patch



