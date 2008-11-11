From: Stephen Hemminger <shemminger@vyatta.com>
Subject: SKB truesize bug
Date: Tue, 11 Nov 2008 09:25:13 -0800
Message-ID: <20081111092513.67c2a988@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46791 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751657AbYKKRZQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2008 12:25:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is this bug fixed?  is it in the 2.6.26.8 kernel?

http://bugzilla.kernel.org/show_bug.cgi?id=10996
