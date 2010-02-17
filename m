From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Recent change to net-next broke KVM bridging
Date: Tue, 16 Feb 2010 17:36:58 -0800
Message-ID: <20100216173658.519b6245@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45076 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933816Ab0BQBhK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2010 20:37:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Something in net-next tree broke bridging of virtual nets.
My local VM's can no longer access external networks.

-- 
