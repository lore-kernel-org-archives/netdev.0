From: David Miller <davem@davemloft.net>
Subject: [README] Merge window has openned
Date: Mon, 01 Oct 2012 00:53:53 -0400 (EDT)
Message-ID: <20121001.005353.1893936334196650641.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netfilter-devel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33599 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750822Ab2JAExz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 00:53:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


You all know what this means.

Anything not in patchwork already is not going to make it into this
merge window.

I'm allowing a minor exception for the bnx2x driver firmware update
which needs a respin to fix build errors.

Please do not submit new features until the merge window closes and I
reopen net-next for development.  Do not ask me for an exception, the
net-next tree was open for about two months.

Bug fixes may be submitted at any time.

I intend to send a pull request to Linus for net-next on Wednesday.

This assumes I can work through the patchwork backlog and get the
bnx2x respin by the end of Monday so that everything gets at least one
day of exposure in linux-next.  So if things don't fall into place by
Monday night I'll push the pull request back a day or two, as needed.

Thanks.
