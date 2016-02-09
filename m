From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] selinux: nlmsgtab: add SOCK_DESTROY to the netlink
 mapping tables
Date: Tue, 09 Feb 2016 04:56:05 -0500 (EST)
Message-ID: <20160209.045605.173757331263146641.davem@davemloft.net>
References: <1454516232-18546-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53888 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754542AbcBIJ4J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 04:56:09 -0500
In-Reply-To: <1454516232-18546-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Thu,  4 Feb 2016 01:17:12 +0900

> Without this, using SOCK_DESTROY in enforcing mode results in:
> 
>   SELinux: unrecognized netlink message type=21 for sclass=32
> 
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>

Applied, thanks Lorenzo.
