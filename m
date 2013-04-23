From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: cpsw queue, v2
Date: Tue, 23 Apr 2013 19:31:34 +0200
Message-ID: <1366738299-21285-1-git-send-email-bigeasy@linutronix.de>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	tglx@linutronix.de
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:36065 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756725Ab3DWRbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 13:31:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

patches one, four and five gained acked-by tags nothing else changed.
Patch two gained pm_runtime_put_sync() and clean up for the slave.
Patch three is a complete redo of the initial patch.

Sebastian
