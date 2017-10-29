From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/4] sctp: a bunch of fixes for some sparse warnings
Date: Sun, 29 Oct 2017 18:04:05 +0900 (KST)
Message-ID: <20171029.180405.85677078762613174.davem@davemloft.net>
References: <cover.1509190967.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        edumazet@google.com, marcelo.leitner@gmail.com,
        nhorman@tuxdriver.com, vyasevich@gmail.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47252 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751080AbdJ2JEJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Oct 2017 05:04:09 -0400
In-Reply-To: <cover.1509190967.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Sat, 28 Oct 2017 19:43:53 +0800

> As Eric noticed, when running 'make C=2 M=net/sctp/', a plenty of
> warnings or errors checked by sparse appear. They are all problems
> about Endian and type cast.
> 
> Most of them are just warnings by which no issues could be caused
> while some might be bugs.
> 
> This patchset fixes them with four patches basically according to
> how they are introduced.

Series applied, thanks.
