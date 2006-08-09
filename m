From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 0/5] net socket family patches
Date: Wed, 09 Aug 2006 11:31:38 -0700
Message-ID: <20060809183138.332023530@localhost.localdomain>
Cc: Paul McKenney <paulmck@us.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:5824 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751306AbWHISkz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 14:40:55 -0400
To: David Miller <davem@davemloft.net>
Cc: akpm@osdl.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches cleanup the net socket family interface and
convert it to RCU. This is new stuff that should go into 2.6.19
(if it is ready). Andrew could you put it in -mm as well?

