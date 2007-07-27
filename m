From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFT 0/4] fib_trie cleanup patches
Date: Fri, 27 Jul 2007 08:59:17 +0100
Message-ID: <20070727075917.470055328@linux-foundation.org>
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:58593 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762715AbXG0IB3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2007 04:01:29 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here is a slightly revised version of the FIB trie cleanup patches.

I don't have a machine with anywhere near enough routes to test this,
so would someone with many routes give it a go and make sure nothing
got busted in the process.

-- 

