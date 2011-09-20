From: David Miller <davem@davemloft.net>
Subject: Re: ppp_generic: fix multilink fragment MTU calculation (again)
Date: Tue, 20 Sep 2011 16:01:48 -0400 (EDT)
Message-ID: <20110920.160148.2060960480978655876.davem@davemloft.net>
References: <4E7681BD.2040902@stuffedcow.net>
	<20110920.152128.1875285861948423018.davem@redhat.com>
	<4E78EF78.7060106@stuffedcow.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: v4l@stuffedcow.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46754 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750967Ab1ITUC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2011 16:02:57 -0400
In-Reply-To: <4E78EF78.7060106@stuffedcow.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Henry Wong <v4l@stuffedcow.net>
Date: Tue, 20 Sep 2011 15:54:32 -0400

> Out of curiosity, were the trailing whitespaces on Lines 10 and 11? Or
> was there a problem with file attachments that cause some whitespace I
> don't see? I'll be more careful next time :)

Both the line before the comment (2 tabs) and the first line of the
comment (one space).
