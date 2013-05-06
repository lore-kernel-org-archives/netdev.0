From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] 3c59x: fix PCI resource management
Date: Mon, 06 May 2013 14:59:37 -0400 (EDT)
Message-ID: <20130506.145937.821236821026536204.davem@davemloft.net>
References: <5187E884.7060101@cogentembedded.com>
	<20130506.135305.1659397370290340459.davem@davemloft.net>
	<5187F512.4070104@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de,
	tedheadster@gmail.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33601 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755334Ab3EFS7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 May 2013 14:59:45 -0400
In-Reply-To: <5187F512.4070104@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Mon, 06 May 2013 22:23:14 +0400

>     How about I completely drop this change (and maybe deal with it in a
>     subsequent cleanup patch)?

Sure, that cleanup would have to wait until after the merge window is
closed and I reopen net-next.

Thanks.
