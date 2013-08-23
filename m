From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: sctp_probe: simplify code by using %pISc
 format specifier
Date: Thu, 22 Aug 2013 22:10:13 -0700 (PDT)
Message-ID: <20130822.221013.71778942538808574.davem@davemloft.net>
References: <1377184370-13721-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57180 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753471Ab3HWFKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 01:10:17 -0400
In-Reply-To: <1377184370-13721-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Thu, 22 Aug 2013 17:12:50 +0200

> We can simply use the %pISc format specifier that was recently added
> and thus remove some code that distinguishes between IPv4 and IPv6.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied.
