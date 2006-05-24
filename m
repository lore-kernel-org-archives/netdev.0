From: Stephen Hemminger <shemminger@osdl.org>
Subject: [patch 0/3] bridge patches for 2.6.18
Date: Wed, 24 May 2006 10:12:16 -0700
Message-ID: <20060524171216.706750000@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:49591 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932416AbWEXRPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 May 2006 13:15:19 -0400
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some stuff for 2.6.18. The most important is adding netlink
support for managing interfaces; this allows building STP
as an application.

--

