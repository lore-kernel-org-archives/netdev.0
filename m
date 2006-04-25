From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 0/5] sky2: version 1.2
Date: Tue, 25 Apr 2006 10:58:49 -0700
Message-ID: <20060425175849.372221000@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:25729 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932258AbWDYVCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2006 17:02:25 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update to sky2 driver. Mostly fixes to try and handle users
stuck with edge-triggered interrupts. Also, some minor cleanups.

Patches apply onto 1.1 version in 2.6.17-rc2

--

