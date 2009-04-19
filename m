From: Stephen Hemminger <shemminger@vyatta.com>
Subject: TCP: Peer messages
Date: Sat, 18 Apr 2009 18:03:03 -0700
Message-ID: <20090418180303.18963ff0@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ilpo =?UTF-8?B?SsOkcnZpbmVu?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42368 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753280AbZDSBDL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Apr 2009 21:03:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Running some log-term tests of (using bittorrent of latest Ubuntu releases).
I see no problems with firewall rules (or sky2 driver), but I do several of these:


[28286.893945] TCP: Peer <ip scrubbed>:63659/51413 unexpectedly shrunk window 414881290:414894358 (repaired)
[47312.851937] TCP: Peer <ip scrubbed>:43793/51413 unexpectedly shrunk window 888816585:888823785 (repaired)
