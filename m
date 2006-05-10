From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 0/2] register_netdevice and sysfs changes
Date: Wed, 10 May 2006 10:14:52 -0700
Message-ID: <20060510171452.619146000@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:65433 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965004AbWEJRRb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 May 2006 13:17:31 -0400
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a signed-off version of yesterday's fix, plus the bridge
code no longer needs to be so tricky.
--

