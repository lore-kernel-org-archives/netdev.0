From: Andrew Morton <akpm@osdl.org>
Subject: baycom_epp.c compile failure
Date: Sun, 10 Dec 2006 00:56:32 -0800
Message-ID: <20061210005632.d980f651.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:34963 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760512AbWLJI4l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Dec 2006 03:56:41 -0500
To: Ralf Baechle <ralf@linux-mips.org>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

drivers/net/hamradio/baycom_epp.c: In function 'baycom_probe':
drivers/net/hamradio/baycom_epp.c:1180: error: 'ax25_nocall' undeclared (first use in this function)
drivers/net/hamradio/baycom_epp.c:1180: error: (Each undeclared identifier is reported only once
drivers/net/hamradio/baycom_epp.c:1180: error: for each function it appears in.)
