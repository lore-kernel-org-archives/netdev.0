From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] mpls: Change reserved label names to be consistent
 with netbsd
Date: Sat, 09 May 2015 22:30:02 -0400 (EDT)
Message-ID: <20150509.223002.1175223507224920971.davem@davemloft.net>
References: <1431011331-1863736-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47563 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752007AbbEJCaF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 22:30:05 -0400
In-Reply-To: <1431011331-1863736-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Thu, 7 May 2015 08:08:51 -0700

> Since these are now visible to userspace it is nice to be consistent
> with BSD (sys/netmpls/mpls.h in netBSD).
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>

Applied, thanks Tom.
