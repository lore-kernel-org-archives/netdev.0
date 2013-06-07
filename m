From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] doc: packet: simplify tpacket example code
Date: Fri, 07 Jun 2013 14:39:26 -0700 (PDT)
Message-ID: <20130607.143926.1179776377737750264.davem@davemloft.net>
References: <1370563693-19599-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48597 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753788Ab3FGVj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jun 2013 17:39:29 -0400
In-Reply-To: <1370563693-19599-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Fri,  7 Jun 2013 02:08:13 +0200

> This patch simplifies the tpacket_v3 example code a bit by getting rid
> of unecessary macro wrappers, removing some debugging code so that it is
> more to the point, and also adds a header comment. Now this example code
> is the very minimum one needs to start from when dealing with tpacket_v3
> and ~100 lines smaller than before.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied.
