From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] follow-up improvements for ipv6 tokens
Date: Tue, 09 Apr 2013 13:12:57 -0400 (EDT)
Message-ID: <20130409.131257.186567335586603485.davem@davemloft.net>
References: <1365515236-7154-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36317 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762769Ab3DIRM7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 13:12:59 -0400
In-Reply-To: <1365515236-7154-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue,  9 Apr 2013 15:47:13 +0200

> This set implements follow-up suggestions from Hannes for commit
> f53adae4eae5ad9 (``net: ipv6: add tokenized interface identifier
> support''). Tested by myself.
> 
> Daniel Borkmann (3):
>   net: ipv6: minor: use in6addr_any in token init
>   net: ipv6: also allow token to be set when device not ready
>   net: ipv6: only invalidate previously tokenized addresses

All applied, thanks Daniel.
