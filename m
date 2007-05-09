From: Andrew Morton <akpm@linux-foundation.org>
Subject: linkwatch bustage in git-net
Date: Tue, 8 May 2007 22:20:33 -0700
Message-ID: <20070508222033.4e57a580.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:35187 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755318AbXEIFVN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 01:21:13 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


My Vaio is taking 5-10x longer to boot when git-net as of five minutes ago
is applied.

It's not very clear what's gone wrong.  A few linkwatch things are showing
up in profiles, but it's not burning excessive CPU afaict.


