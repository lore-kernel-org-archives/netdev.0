From: Stephen Hemminger <shemminger@vyatta.com>
Subject: IPv6 /127 address
Date: Thu, 30 Jun 2011 10:47:13 -0700
Message-ID: <20110630104713.52e085dd@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44544 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752194Ab1F3RrR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2011 13:47:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a new RFC out for supporting /127 addresses for
router interconnect and point-to-point links.

Right now the kernel gets confused by the /127 and doesn't
disable the anycast address. Any ideas?

 http://tools.ietf.org/html/rfc6164
 http://lists.debian.org/debian-ipv6/2011/05/msg00018.html
