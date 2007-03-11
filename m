From: ralf@linux-mips.org
Subject: [PATCH 0/3] AX.25, NETROM and ROSE fixes and cleanups
Date: Sun, 11 Mar 2007 22:53:19 +0000
Message-ID: <20070311225319.673076841@denk.linux-mips.net>
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:53539 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964792AbXCKXSx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Mar 2007 19:18:53 -0400
Received: from localhost.localdomain ([127.0.0.1]:25824 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20022215AbXCKXSx (ORCPT <rfc822;netdev@vger.kernel.org>
	+ 1 other); Sun, 11 Mar 2007 23:18:53 +0000
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patches 1/3 and 2/3 are fixes for 2.6.21 and -stable.  3/3 is a cleanup
even though it seems to partly paper over a connection establishment issue
on extremly fast networks such as loopback I'm still chasing.

  Ralf

