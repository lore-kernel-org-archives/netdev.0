From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] SCTP fixes
Date: Tue, 14 Oct 2014 12:46:57 -0400 (EDT)
Message-ID: <20141014.124657.128658692728989163.davem@davemloft.net>
References: <1412888133-833-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42561 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754214AbaJNQq7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 12:46:59 -0400
In-Reply-To: <1412888133-833-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Thu,  9 Oct 2014 22:55:30 +0200

> Here are some SCTP fixes.
> 
> [ Note, immediate workaround would be to disable ASCONF (it
>   is sysctl disabled by default). It is actually only used
>   together with chunk authentication. ]

Series applied, thanks guys.
