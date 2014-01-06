From: David Miller <davem@davemloft.net>
Subject: 'net' README
Date: Mon, 06 Jan 2014 17:02:40 -0500 (EST)
Message-ID: <20140106.170240.1326748737325484507.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35091 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751470AbaAFWCn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 17:02:43 -0500
Received: from localhost (nat-pool-rdu-t.redhat.com [66.187.233.202])
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 9ADFA587C72
	for <netdev@vger.kernel.org>; Mon,  6 Jan 2014 14:02:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I intend to shortly submit what I hope is the final set of networking
fixes to Linus for 3.13

Please give extra consideration to any bug fixes you might be thinking
about sending from this point forward.

Is it REALLY necessary?  Does it impact significantly a large group of
users?

If you can't answer yes to those two questions, at a minimum, just
target it to net-next.

Thanks.
