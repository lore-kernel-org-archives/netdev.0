From: Andreas Fenkart <andreas.fenkart@streamunlimited.com>
Subject: [PATCH 0/5] ARC vmac ethernet driver.
Date: Tue,  2 Mar 2010 00:18:02 +0100
Message-ID: <1267485483-15298-1-git-send-email-andreas.fenkart@streamunlimited.com>
References: <20100222.154010.149123575.davem@davemloft.net>
Cc: amit.bhor@celunite.com, sameer.dhavale@celunite.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:50856 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752628Ab0CAXRM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Mar 2010 18:17:12 -0500
In-Reply-To: <20100222.154010.149123575.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a resend of previous submission. It contains the following
changes:

* Removed arcvmac_fifo.h, moved content to arcvmac.h

* Replaced BUG_ON with WARN_ON

* Added missing Kconfig entry
