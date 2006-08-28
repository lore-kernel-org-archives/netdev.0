From: shemminger@osdl.org
Subject: [PATCH 0/9]  sky2 1.7 non-critical bug fixes
Date: Mon, 28 Aug 2006 10:00:44 -0700
Message-ID: <20060828170044.136391412@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:18050 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751174AbWH1SQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2006 14:16:09 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These are a set of non-critical fixes to the sky2 driver.
  1. cloned skb tso bug fix
  2. netdev_alloc_skb
  3. don't use force status on transmit
  4. MSI pci posting bug
  5. TSO segment size optimization
  6. checksum offload optimization
  7. power up PHY only on network open
  8. pci post bug before delay
  9. version 1.7

