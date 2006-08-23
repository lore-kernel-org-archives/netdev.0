From: shemminger@osdl.org
Subject: [PATCH 0/4]  bridge-netfilter fixes
Date: Tue, 22 Aug 2006 17:10:50 -0700
Message-ID: <20060823001050.363374000@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:34782 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750749AbWHWATK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2006 20:19:10 -0400
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This set of patches fixes issues with bridge netfilter code.
First patch is for 2.6.18 and fixes a crash. Later patches
could be deferred, they just cleanup the style, usage, etc.

--


