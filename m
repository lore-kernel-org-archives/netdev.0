From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net 0/4] ipv4: various pmtu discovery fixes
Date: Tue, 11 Oct 2011 13:08:42 +0200
Message-ID: <20111011110842.GC1830@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:43606 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751407Ab1JKLIp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 07:08:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset addresses some issues I found during investigating
pmtu discovery. These issues were introduced with
git commit 2c8cec5 (ipv4: Cache learned PMTU information in inetpeer).

The patchset is based on current net/master.

Steffen
