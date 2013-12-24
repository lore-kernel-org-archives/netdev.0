From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] tipc: do some fixups
Date: Tue, 24 Dec 2013 17:45:41 -0500 (EST)
Message-ID: <20131224.174541.2213038026686672610.davem@davemloft.net>
References: <1387263827-20876-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, allan.stephens@windriver.com,
	David.Laight@ACULAB.COM, netdev@vger.kernel.org
To: wangweidong1@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39114 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751128Ab3LXWpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Dec 2013 17:45:45 -0500
In-Reply-To: <1387263827-20876-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Referring to commit purely by SHA1 ID is ambiguous.

If the change is placed in other trees, such as the -stable
branches, they will have different SHA1 IDs.

This is why you must always refer to commits as the
SHA1 ID followed by the commit header line text of
the commit in parenthesis and double quotes, like
this:

Commit 0cee6bbe06f ("tipc: remove unnecessary variables and conditions")

Please fix this up in this entire patch series and resubmit.
